# Code contribution

Before you contribute some code, please review the following aspects of this project:

- See [High-level MVP defintion](https://docs.google.com/document/d/1dJ2tcwCXUh4Cpj0-J5-EJHFuHmrdADM57vt0fHdPcfI/edit#heading=h.hk64tiarsl4z ) that specifies what we are trying to build.
- See [actors](./actors.md) of this system
- See [entity model](./entityModel.wsd) this is a desired state to which we should converge. Attributes that are not important for business are left out. (if you think they should be there, open a PR)

**[JOIN OUR SLACK, where we coordinate development.](https://join.slack.com/t/pomuzemesi/shared_invite/zt-ct442m1c-lXFlSXDmWgVxcdh9CTXjGg)**

## Business logic

Business logic is written into service objects. One service class per use case. Service classes are grouped by modules.

We use the pattern as described in this [guide](https://www.toptal.com/ruby-on-rails/rails-service-objects-tutorial)

## Technologies and libraries

**Following libraries and technologies are used:**

- [Devise](https://github.com/heartcombo/devise) authentication gem with strong password check. But please no unicorns.
  - For email templates override device’s I18n locales to personalize translations
- [CanCanCan](https://github.com/CanCanCommunity/cancancan) authorization. Make two or three roles (admin, superadmin, coordinator)
- [Rolify](https://github.com/RolifyCommunity/rolify) - user roles management
- [Sidekiq](https://github.com/mperham/sidekiq) as activejob backend
- [ActiveAdmin](https://github.com/activeadmin/activeadmin) for scaffolding controllers
- [rspec](https://github.com/rspec/rspec-rails) for unit/inegration testing
- Postgres with postgis extension. Use [activerecord-postgis-adapter](https://github.com/rgeo/activerecord-postgis-adapter)
- Google geolocation api - need to find appropriate gem, maybe [geocoder](https://github.com/alexreisner/geocoder)

## Definition of Done

This is the minimal definition of done that every code contribution must adhere to

- Code implements the desired functionality
- You have seen the code work (you have clicked through the UI / tried it in console)
- Documentation exists on the level of Service objects
- [Entity model](./entityModel.wsd) is updated if a change to the entities was made
- Tests are written at least on the service object level
- Please, **where viable, include screenshot or gif or video recording of your functionality in the PR** so that PO can determine quickly if this fulfills the business requirements
