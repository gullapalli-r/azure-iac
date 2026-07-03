/**
 * @param {typeof import("fs").promises} fs
 * @param {string} dir
 */
async function getSubdirNames(fs, dir) {
  var files = await fs.readdir(dir, { withFileTypes: true });
  return files.filter((x) => x.isDirectory()).map((x) => x.name);
}

/**
 * @typedef Params
 * @property {typeof require} require
 * @property {typeof import("@actions/core")} core
 * @property {typeof require("@azure/container-registry").ContainerRegistryClient} registry
 *
 * @param {Params} params
 */
async function generateModuleIndexData({ require, core, registry }) {
  const fs = require("fs").promises;
  const moduleGroups = await getSubdirNames(fs, "modules");

  var moduleIndexData = [];

  const path = require("path");

  for (const moduleGroup of moduleGroups) {
    var moduleGroupPath = path.join("modules", moduleGroup);
    var moduleNames = await getSubdirNames(fs, moduleGroupPath);

    for (const moduleName of moduleNames) {
      const modulePath = `${moduleGroup}/${moduleName}`;
      const repositoryName = `bicep/${modulePath}`;

      try {
        core.info(`Getting ${modulePath}...`);

        const repository = registry.getRepository(repositoryName);
        let tags = [];
        for await (const manifest of repository.listManifestProperties({
          order: "LastUpdatedOnAscending",
        })) {
          tags = tags.concat(manifest.tags);
        }

        moduleIndexData.push({
          moduleName: modulePath,
          tags: tags,
        });
      } catch (error) {
        core.setFailed(error);
      }
    }
  }

  await fs.writeFile(
    "moduleIndex.json",
    JSON.stringify(moduleIndexData, null, 2),
  );
}

module.exports = generateModuleIndexData;
