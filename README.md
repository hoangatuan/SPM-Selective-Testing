
# Steps

0. Run test for all project, process the xctest result to calculate the code coverage, hash for each targets. Then store the result as a cache on another repo. (
1. Generate all the targets and relationships from Podfile & Podfile.lock
2. Calculate the hash for each target and the target's test.
3. Figure out which target need be test again?
4. Update the coverage to the cache repo

# Idea

1. Subcommand to init configuration file
2. subcommand to run the full flow
3. Subcommand to get the dependencies only

# References

1. Calculate coverages for each targets: https://github.com/ronanociosoig-200/Tuist-Pokedex/blob/master/scripts/readCodeCoverage.swift
2. https://github.com/grab/cocoapods-binary-cache?tab=readme-ov-file
3. https://docs.tuist.io/cloud/hashing#debugging
4. https://docs.tuist.io/cloud/binary-caching#cache-warming
5. https://github.com/tuist/tuist/pull/1765
6. https://github.com/tuist/tuist/issues/1828
7. https://github.com/Ryu0118/swift-dependencies-graph (using swift package dump-package to get all the dependencies)
