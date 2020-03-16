# Code contribution

Before you contribute some code, please review the following aspects of this project:

## Architecture

---

Pomuzeme.si - consists of two modules - landing page and administration interface

### Business logic

Business logic is written into service objects. One service class per use case. Service classes are grouped by modules.

We use the pattern as described in this [guide](https://www.toptal.com/ruby-on-rails/rails-service-objects-tutorial)

### Technologies and libraries

**Following libraries and technologies are used:**

- [Devise](https://github.com/heartcombo/devise) authentication gem with strong password check. But please no unicorns.
  - For email templates override device’s I18n locales to personalize translations
- [CanCanCan](https://github.com/CanCanCommunity/cancancan) authorization. Make two or three roles (admin, superadmin, coordinator)
- [Rolify](https://github.com/RolifyCommunity/rolify) - user roles management
- [Sidekiq](https://github.com/mperham/sidekiq) as activejob backend
- [ActiveAdmin](https://github.com/activeadmin/activeadmin) for scaffolding controllers
- Postgres with postgis extension. Use [activerecord-postgis-adapter](https://github.com/rgeo/activerecord-postgis-adapter)
- Google geolocation api - need to find appropriate gem, maybe [geocoder](https://github.com/alexreisner/geocoder)
