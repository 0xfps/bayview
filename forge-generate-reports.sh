rm forge-coverage.info
rm lcov.info
rm forge\ --report\ debug.info

forge coverage >> forge-coverage.info
echo "Generated Coverage."

forge coverage --report lcov >> lcov.info
echo "Generated Lcov."

forge coverage --report debug >> forge\ --report\ debug.info
echo "Generated Debug."