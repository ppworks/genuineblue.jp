# genuineblue.jp

## Setup for development

rename Guardfile.example to Guardfile

```
$ cp Guardfile.example Guardfile
```

## External API Credential

```
cp config/application.yml.example config/application.yml
```

Fill in api credential

```
rake secret
```

Fill in SECRET_TOKEN by the key above result.

```
rake secret
```

Change devise's secret_token(config/initializers/devise.rb) by the key above result.

## Start guard

```
$ guard
```
