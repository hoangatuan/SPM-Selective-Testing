
# 🔎 SPM Selective Testing 

![Static Badge](https://img.shields.io/badge/status-active-brightgreen)

This is a tool to help you run only the tests that have changed since the last successful test run, instead of re-run all the tests every time.

<img src=Resources/result.png width=800/>

# Table of Contents

- [Why](#why)
- [Selective Testing?](#selective-testing)
- [Installation](#installation)
- [Usage](#usage)
- [How it works](#how-it-works)
- [Publication](#publication)

## Why

As the project grows, more and more tests are added. It makes **the time to run all the tests increase dramatically**.   
As your team grows, more and more times your team and your CI need to run the tests.   
Especially on CI, we normally clean and re-run all the tests, **regardless of the changes**.   
With `spm-selective-testing`, we can **run only the tests that have changed since the last successful test run**, reducing the time to run the tests significantly. 🚀

## Selective Testing?

As mentioned above, selective testing can **run only the tests that have changed**.  
So what is tests that have changed?

| A test target is marked as changed if its dependencies or its source code has changed.

For example, assuming the following dependency graph:

FeatureA has tests FeatureATests, and depends on Core
FeatureB has tests FeatureBTests, and depends on Core
Core has tests CoreTests

| Action    | Description |
| -------- | ------- |
| FeatureA soure code changed | Only FeatureATests is marked as changed |
| FeatureB soure code changed | Only FeatureBTests is marked as changed |
| Core source code changed | FeatureATests, FeatureBTests and CoreTests are marked as changed |


## Installation

You can go to [GitHub Releases](https://github.com/hoangatuan/SPM-Selective-Testing/releases) page to download release executable program
(This project is still in the development phase, and not ready for production.)

## Usage

```bash
    // Init a default configuration for your project
    spm-test-selective init

    // Perform selective testing
    spm-test-selective $PROJECT-PATH $TEST-PLAN-PATH
```

## How it works

<img src=Resources/flow.png/>

1. Find all SPM modules in the project
2. [Generate hashes for all SPM modules](./Docs/modules-hashing.md)
3. For each module, compare its current hash with its cache hash.
4. If any module's hash is different from its cache hash, add that module to the test plan. Otherwise, disable that module in the test plan.
5. Run tests with the test plan.
6. If run tests successfully, update the cache.

## Publication

- In progress
