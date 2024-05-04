
# Steps

- Click on run test
-> Generate targets dependencies based on Package.resolved ✅
-> Generate hash for all targets. ✅
-> Check if already has a cache file? 
    + YES: 
        + Compare the hash of the current targets with the hash in the cache file ✅
        + Get all the targets that needs to be run ✅
    + NO: (first run)
        + Create cache file to store all the hashes ✅ 
        + All test target must need to be run ✅
-> Run test targets that changed
-> Process the xctestrun file to get the coverage
-> Update cache file with new hashes
-> Return result

# Note

- The hash for the target should be calculate by:
  + The target's attributes (e.g., name, platform, product, etc.).
  + The target's files
  + The hash of the target's dependencies
  + swift version?
  Ref: https://docs.tuist.io/cloud/hashing.html

# Idea

1. Subcommand to init configuration file
2. subcommand to run the full flow
3. Subcommand to get the dependencies only
4. provide a `config.yaml` file to let user define: direct depend framework of main project, excludes targets/test targets, test targets that needs to be run (if empty run all the test targets)

# Edge case to check

- a product contains multiple targets
- A target that has custom `excludes`
- A target that has custom `sources`
- A dependencies of type `framework`   

# Note

- If a target has the path = nil => Swift Package Manager looks for a target's source files at predefined search paths and in a subdirectory with the target's name.
    The predefined search paths are the following directories under the package root:
        + `Sources`, `Source`, `src`, and `srcs` for regular targets
        + `Tests`, `Sources`, `Source`, `src`, and `srcs` for test targets
        
- If sources = nil => SPM includes all valid source files in the target's path. Otherwise, Swift Package Manager searches for valid source files recursively inside the path

# References

1. Calculate coverages for each targets: https://github.com/ronanociosoig-200/Tuist-Pokedex/blob/master/scripts/readCodeCoverage.swift
2. https://github.com/grab/cocoapods-binary-cache?tab=readme-ov-file
3. https://docs.tuist.io/cloud/hashing#debugging
4. https://docs.tuist.io/cloud/binary-caching#cache-warming
5. https://github.com/tuist/tuist/pull/1765
7. Selective test: https://github.com/tuist/tuist/pull/2422
8. Generate test scheme: https://github.com/tuist/tuist/pull/2057
9. https://github.com/Ryu0118/swift-dependencies-graph (using swift package dump-package to get all the dependencies)
10. [PackageDescription](https://developer.apple.com/documentation/packagedescription)
