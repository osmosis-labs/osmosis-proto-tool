# osmosis-proto-tool

Used for generating client en/decoders and TypeScript types for a cherry-picked subset of Cosmos SDk and Osmosis proto files.

## Steps

Goal: generate new codecimpl.js and codecimpl.d.ts files that can be used on [osmosis-frontend](https://github.com/osmosis-labs/osmosis-frontend).

All commands to be run at root of repo. They will sparse clone the proto folders of the necessary repos the first time, and fetch them later as needed.

1. Ensure cosmos-sdk version is the desired version in the env var in 1-get-proto.sh.
2. Run 1-get-proto.sh and optionally pass in a commit hash of Osmosis repo to get protos from. (i.e. `./1-get-proto.sh 73881c649c7334090436ff29123b016e9ac2eba9`)
3. Install Node.js (`brew install node`) and yarn (`npm install -g yarn`) and run `yarn` to install JS dependencies.
4. In 2-gen-coders.sh, arguments to `yarn pbjs` to include paths to all needed proto files in `proto` folder, edit to include any new protos.
5. Run 2-gen-coders.sh to generate the codecimpl.js file.
6. Run 3-gen-types.sh to generate types from the codecimpl.js. Update args to `yarn tsc` as needed.
7. Look in output/ folder for your js and .d.ts files.
