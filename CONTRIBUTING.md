# Contribution

You want to contribute to `pass tomb`, **thank a lot for this.** You will find
in this page all the useful information needed to contribute.

## How to run the tests?

`pass-tomb` has a complete test suite that provide functional and unit tests
for all the parts of the program. Moreover, it provides test coverage and code
health reports.

In order to run the tests, you need to install the following program(s):
* [kcov][kcov] as coverage system for bash.

The tests require `sudo` access, and the generated tomb are written in
`/tmp/pass-tomb`. To run the tests, simply run: `make tests`


## How to contribute?

1. If you don't have git on your machine, [install it][git].
2. Fork this repo by clicking on the fork button on the top of this page.
3. Clone the repository and go to the directory:
```sh
git clone  https://github.com/this-is-you/pass-tomb.git
cd pass-import
```
4. Create a branch:
```sh
git checkout -b my_contribution
```
5. Make the changes and commit:
```sh
git add <files changed>
git commit -m "A message for sum up my contribution"
```
6. Push changes to GitHub:
```
git push origin my_contribution
```
7. Submit your changes for review: If you go to your repository on GitHub,
you'll see a Compare & pull request button, fill and submit the pull request.

[kcov]: https://github.com/SimonKagstrom/kcov
[git]: https://help.github.com/articles/set-up-git/
