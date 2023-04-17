# osmosis-proto-tool

Used for generating client en/decoders and TypeScript types for a cherry-picked subset of Cosmos SDk and Osmosis proto files.

## Steps

Goal: generate new codecimpl.js and codecimpl.d.ts files that can be used on [osmosis-frontend](https://github.com/osmosis-labs/osmosis-frontend).

All commands to be run at root of repo.

1. Ensure cosmos-sdk version is the desired version in 1-get-sdk-proto.sh.
2. Add an `osmosis` folder in the `proto` folder containing all needed Osmosis proto files
3. Install `yarn` and run `yarn` to install JS dependencies.
4. In 2-gen-coders.sh, arguments to `yarn pbjs` to include paths to all needed proto files in `proto` folder.
5. Run 2-gen-coders.sh to generate the codecimpl.js file.
6. Run 3-gen-types.sh to generate types from the codecimpl.js. Update args to `yarn tsc` as needed.
