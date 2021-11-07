# Family Chore Management App

This is the source code from an old startup I worked on that failed. The idea was to create a mobile app that parents and kids could use to manage family chores. The unique idea was parents could create multiple types of currencies to track and 'pay' children in (like screentime).

It never took off. Posting the source here in case it's useful to anyone. It's a rails app with a ionic-based mobile app. It's pretty old source code (~2015).

Some unedited notes included below.

---


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
