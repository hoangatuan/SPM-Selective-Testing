
# 🔎 SPM Test Selective 

![Static Badge](https://img.shields.io/badge/status-active-brightgreen)

This is a tool to help you run only the tests that have changed since the last successful test run, instead of re-run all the tests everytime.

<img src=Resources/result.png width=800/>

# Table of Contents

- [Why](#why)
- [Installation](#installation)
- [Usage](#usage)
- [How it works](#how-it-works)
- [Publication](#publication)

## Why

As the project grows, more and more tests are added to the project. It makes the time to run all the tests increase drammatically.   
As your team grow, more and more number of times your team and your CI need to run the tests.   
Especially on CI, we normally clean and re-run all the tests, regardless of the changes.   
With `spm-test-selective", we can run only the tests that have changed since the last successful test run, which will reduce the the time to run the tests significantly. 🚀

## Installation

Currently this project is still in development phrase, not ready for production.

## Usage

The most simple way to run the leaks checking process is:

```bash
    testselective init
    testselective $PROJECT-PATH $TEST-PLAN-PATH
```

## How it works

<img src=Resources/flow.png/>

1. Find all SPM modules in the project
2. Generate hashes for all SPM modules
3. For each module, compare its current hash with its cache hash.
4. If any module's hash is different from its cache hash, add that module to the test plan. Otherwise, disable that module in test plan.
5. Run test with the test plan
6. If test successfully, update cache.

## Publication

- In progress
