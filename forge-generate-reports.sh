rm forge-coverage.info
rm lcov.info
rm forge --report debug.info

forge coverage >> forge-coverage.info
forge coverage --report lcov >> lcov.info
forge coverage --report debug >> forge\ --report\ debug.info