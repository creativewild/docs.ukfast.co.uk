## External

This is really just a placeholder, this will all be on github when we go live. It's for any documentation that's to be public facing.

## Branches/Structure

* `master` is just for completed articles
* `in-progress` branch has stubs/blanks/things that need reviewing. A diff of the two branches to find incomplete articles can be found with:
```
    git diff --name-status master..in-progress|grep "^A"
```
* `caketheme` branch is for the new theme. Content likely isn't up to date, it's just for design purposes. Massive changes to structure and Makefile.
* TODO document, suprisingly, is for things that need doing.

## Builds
Various gitlab-ci configs build the branches:

* Commits to master will build to http://extdocs.testops.ukfast.co.uk/
* Commits to caketheme will build to http://extcaketheme.testops.ukfast.co.uk/
* Any other branch, providing you carry the gitlab-ci.yml over, will build to http://extbranchbuild.docs.testops.ukfast.co.uk/${BRANCHNAME} on push


## Install
* Clone this, cd inside
* pip install sphinx
* pip install recommonmark
* git submodule update --init
* make clean && make html
* Point nginx at build/html
