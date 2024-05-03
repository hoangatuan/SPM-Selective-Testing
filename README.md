
# Steps

0. Run test for all project, process the xctest result to calculate the code coverage, hash for each targets. Then store the result as a cache on another repo. (
1. Generate all the targets and relationships from Podfile & Podfile.lock
2. Calculate the hash for each target and the target's test.
3. Figure out which target need be test again?
4. Update the coverage to the cache repo

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
4. provide a `config.yaml` file to let user define: direct depend framework of main project, excludes targets

# Edge case to check

- a product contains multiple targets
- A target that has custom `excludes`
- A target that has custom `sources`

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
