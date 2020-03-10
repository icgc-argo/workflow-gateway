# workflow-gateway

## Release
To make a release, update the `VERSION` file. Merging into develop will result in `<tag>-<num>-<commitid>` docker tag. Merging into master will read the value stored in `VERSION` and push that tag to the master branch and make that the docker tag.


