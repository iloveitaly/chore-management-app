You'll have to create an account with Apple and then build.phongap.com (the first is paying, not the second) to generate the file you can actually upload to iTunes. As a warning, Apple makes the process as painful and annoying as it can be... Not much we can do about that... Here is where to start https://developer.apple.com/.

http://family-currency.herokuapp.com/

http://staging-family-currency.herokuapp.com

git push heroku `git subtree split --prefix web master`:master --force

https://console.developers.google.com/apis/credentials?project=family-currency

https://blog.bubble.is

https://itunes.apple.com/gy/app/bubble-account/id976171065?mt=8

http://forum.bubble.is/t/native-mobile-app/191/3

http://app.phonegap.com

support@bubble.is

when setting up google credentials, from omniauth:

>Note: You must enable the "Contacts API" and "Google+ API" via the Google API console. Otherwise, you will receive an OAuth2::Error stating that access is not configured when you attempt to authenticate.

```
sudo npm install -g phonegap
brew install ios-sim
phonegap

phonegap serve
ngrok -subdomain=family-currency 192.168.2.4:3000
```

- Transaction log should be formatted with a currency symbol
- There should be a consistent header across the entire app (sans possibly some splash screens)
- Portait orientation only

Add to dotfiles

```
npm install -g gulp
npm update -g cordova ionic
```

# Heroku

```
heroku labs:enable runtime-dyno-metadata
```

# Scripts

```
puts Transaction.where(created_at: (DateTime.now - 4.weeks)..DateTime.now).inject({}) { |h,t| h[t.account.family.id] ||= 0; h[t.account.family.id] += 1; h }.select {|k,v| v > 4 }

TODO filter out demo users and chris

map(&:account).map(&:family).uniq.map(&:name).join("\n")
```

# Delete User

```
# user record
user = User.find_by(email: 'pallas.lvs@gmail.com')

# family

family = user.family

# children

children = family.children

# accounts

accounts = family.accounts.unscope(where: :deleted_at)

# transactions

transactions = accounts.map(&:transactions).flatten

# delete all of the things

transactions.map(&:delete)
accounts.delete_all
children.map(&:delete)
