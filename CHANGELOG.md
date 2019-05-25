## 1.1.0

- Improve handling of unambiguous compact dates
    - __Technically a slight breaking change__, in that dates are compact dates are handled more consistently. For example, given a date like "10/20/2000", the month will always be 10 because it can't be 20, regardless of any compact date format set in the constructor.

## 1.0.2

- Update `README.md` title (package name already at the top of the page on pub)

## 1.0.1

- Fix `README.md` typo

## 1.0.0

- Documentation fixes
- Fix version constraint; require dart 2.3

## 0.3.1

- Standardize formatting and documentation

## 0.3.0

- Add date parsing

## 0.2.8

- Make the deployment script executable

## 0.2.7

- Manual Travis deployment because "deploy:" doesn't appear to work

## 0.2.6

- Skip cleanup 

## 0.2.5

- Yet more Travis fixes

## 0.2.4

- More Travis fixes

## 0.2.3

- Configure deployment script `deploy.sh`

## 0.2.2

- Configure Travis and Coveralls

## 0.2.1

- Updated `README.md`
- Name parsing example (`name_example.dart`)

## 0.2.0

- Name parsing with documentation, testing, and diagnostics

## 0.1.0

- Name parsing functional
    - TODO: better documentation, testing, diagnostics

## 0.0.1

- Add project configuration files
- Initial version, created by Stagehand
