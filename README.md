# Teamtable API

Teamtable is a project management web application made for the web development course at HTW Berlin by [Janis Schanbacher](https://github.com/janis-schanbacher) and [Florian Wolf](https://github.com/flo-wolf).
This repository is the [Ruby on Rails](https://rubyonrails.org/) backend, which provides a RESTful API. The React frontend can be found [here](https://github.com/https://github.com/teamtable/teamtable) and tested at: [teamtable.io](http://teamtable.io).

## Getting started

### Prerequisites
- [Ruby](https://www.ruby-lang.org/en/) version 2.5.3
- [Bundler](https://github.com/teamtable/teamtable-api.git)

### Installation

- Clone the repository to your local machine
  ```sh
  $ git clone https://github.com/teamtable/teamtable-api.git
  ```

- Install the needed gems from within the repository:
  ```sh
  $ cd teamtable-api
  $ bundle install --without production
  ```
- Migrate the database:
  ```sh
  $ rails db:migrate
  ```

> The following two steps are required in order to access credentials and other encrypted files.
- Create a file config/master.key
  ```sh
  $ touch config/master.key
  ```
- Ask one of the developers for the masterkey and insert it into `config/master.key`
  ```sh
  $ echo "replace with masterkey" >> config/master.key
  ```

- Finally, run the test suite to verify that everything is working correctly:
  ```sh
  $ rails test
  ```

- If the test suite passes, you'll be ready to run the app in a local server:
  ```sh
  $ rails server -p 3001
  ```


## Features
 The following functionalities are implemented in the API
- User registration, e-mail confirmation, passwod reset
- Token authentication (using devise, devise-jwt), authorization
- Projects, lists, cards and tags
- Memberships and assignments
- Multilanguage


## Usage
To use the application locally run `$ rails server -p 3001` and use the following request base URL: `http://localhost:3001`

- Sign up
  ```sh
  $ curl -X POST \
    https://teamtable-api.herokuapp.com/signup \
    -H 'Content-Type: application/json' \
    -d '{
      "user": {
        "name": "Test User",
        "email": "test.user@mail.com",
        "password": "password",
        "password_confirmation": "password"
      },
      "locale" : "en"
    }'
  ```

- Log in
  ```sh
  $ curl -X POST \
    https://teamtable-api.herokuapp.com/login \
    -H 'Content-Type: application/json' \
    -d '{
      "user": {
        "email": "test.user@mail.com",
        "password": "password"
      }
    }'
  ```
> copy authorization header from response and use for requests that require authentication

- Create Project
  ```sh
  $ curl -X POST \
    https://teamtable-api.herokuapp.com/projects \
    -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI4Iiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNTU1OTYyMDA3LCJleHAiOjE1NTYwNDg4MDcsImp0aSI6ImEzMGViZjI1LTIyNWYtNDg3NS05NTVjLTEyM2RiNjViYzE0NSJ9.Zjc5zsyNToFVS3N_QTofxdoR4oWUyIdsELum6SLMbh4' \
    -H 'Content-Type: application/json' \
    -d '{
      "project" : {
        "title" : "new project",
        "description" : "project description"
      }
    }'
  ```

- Create List
  ``` sh
  $ curl -X POST \
    https://teamtable-api.herokuapp.com/lists \
    -H 'Authorization: Bearer <Token>' \
    -H 'Content-Type: application/json' \
    -d '{
      "list" : {
        "title" : "new list",
        "description" : "list description",
        "project_id": "1"
      }
    }'
  ```

- Create Card
  ```sh
  $ curl -X POST \
    https://teamtable-api.herokuapp.com/cards \
    -H 'Authorization: Bearer <Token>' \
    -H 'Content-Type: application/json' \
    -d '{
      "card" : {
        "title" : "new card",
        "description" : "card description",
        "list_id": "1"
      }
    }'
  ```

- Get all lists (including cards) of current project
  ```sh
  $ curl -X GET \
    https://teamtable-api.herokuapp.com/lists \
    -H 'Authorization: Bearer <Token>' \
    -H 'Content-Type: application/json'
  ```

### Available routes

```ruby
$ rails routes
                   Prefix Verb   URI Pattern                                                                              Controller#Action
         new_user_session GET    /login(.:format)                                                                         sessions#new {:format=>:json}
             user_session POST   /login(.:format)                                                                         sessions#create {:format=>:json}
     destroy_user_session DELETE /logout(.:format)                                                                        sessions#destroy {:format=>:json}
        new_user_password GET    /password/new(.:format)                                                                  passwords#new {:format=>:json}
       edit_user_password GET    /password/edit(.:format)                                                                 passwords#edit {:format=>:json}
            user_password PATCH  /password(.:format)                                                                      passwords#update {:format=>:json}
                          PUT    /password(.:format)                                                                      passwords#update {:format=>:json}
                          POST   /password(.:format)                                                                      passwords#create {:format=>:json}
 cancel_user_registration GET    /signup/cancel(.:format)                                                                 registrations#cancel {:format=>:json}
    new_user_registration GET    /signup/sign_up(.:format)                                                                registrations#new {:format=>:json}
   edit_user_registration GET    /signup/edit(.:format)                                                                   registrations#edit {:format=>:json}
        user_registration PATCH  /signup(.:format)                                                                        registrations#update {:format=>:json}
                          PUT    /signup(.:format)                                                                        registrations#update {:format=>:json}
                          DELETE /signup(.:format)                                                                        registrations#destroy {:format=>:json}
                          POST   /signup(.:format)                                                                        registrations#create {:format=>:json}
    new_user_confirmation GET    /confirmation/new(.:format)                                                              confirmations#new {:format=>:json}
        user_confirmation GET    /confirmation(.:format)                                                                  confirmations#show {:format=>:json}
                          POST   /confirmation(.:format)                                                                  confirmations#create {:format=>:json}
          new_user_unlock GET    /unlock/new(.:format)                                                                    devise/unlocks#new {:format=>:json}
              user_unlock GET    /unlock(.:format)                                                                        devise/unlocks#show {:format=>:json}
                          POST   /unlock(.:format)                                                                        devise/unlocks#create {:format=>:json}
                 projects GET    /projects(.:format)                                                                      projects#index
                          POST   /projects(.:format)                                                                      projects#create
                  project GET    /projects/:id(.:format)                                                                  projects#show
                          PATCH  /projects/:id(.:format)                                                                  projects#update
                          PUT    /projects/:id(.:format)                                                                  projects#update
                          DELETE /projects/:id(.:format)                                                                  projects#destroy
              memberships GET    /memberships(.:format)                                                                   memberships#index
                          POST   /memberships(.:format)                                                                   memberships#create
               membership GET    /memberships/:id(.:format)                                                               memberships#show
                          DELETE /memberships/:id(.:format)                                                               memberships#destroy
          current_project GET    /current-project(.:format)                                                               projects#current
          project_members GET    /projects/:id/members(.:format)                                                          projects#members
             project_tags GET    /projects/:id/tags(.:format)                                                             projects#tags
            project_lists GET    /projects/:id/lists(.:format)                                                            projects#lists
                    lists GET    /lists(.:format)                                                                         lists#index
                          POST   /lists(.:format)                                                                         lists#create
                     list GET    /lists/:id(.:format)                                                                     lists#show
                          PATCH  /lists/:id(.:format)                                                                     lists#update
                          PUT    /lists/:id(.:format)                                                                     lists#update
                          DELETE /lists/:id(.:format)                                                                     lists#destroy
         list_memberships GET    /list_memberships(.:format)                                                              list_memberships#index
                          POST   /list_memberships(.:format)                                                              list_memberships#create
          list_membership GET    /list_memberships/:id(.:format)                                                          list_memberships#show
                          DELETE /list_memberships/:id(.:format)                                                          list_memberships#destroy
             list_members GET    /lists/:id/members(.:format)                                                             lists#members
                list_tags GET    /lists/:id/tags(.:format)                                                                lists#tags
               list_cards GET    /lists/:id/cards(.:format)                                                               lists#cards
     list_update_position PATCH  /lists/:id/position(.:format)                                                            lists#update_position
list_positions_update_all PATCH  /list-positions(.:format)                                                                list_positions#update_all
                    cards GET    /cards(.:format)                                                                         cards#index
                          POST   /cards(.:format)                                                                         cards#create
                     card GET    /cards/:id(.:format)                                                                     cards#show
                          PATCH  /cards/:id(.:format)                                                                     cards#update
                          PUT    /cards/:id(.:format)                                                                     cards#update
                          DELETE /cards/:id(.:format)                                                                     cards#destroy
              assignments POST   /assignments(.:format)                                                                   assignments#create
               assignment PATCH  /assignments/:id(.:format)                                                               assignments#update
                          PUT    /assignments/:id(.:format)                                                               assignments#update
                          DELETE /assignments/:id(.:format)                                                               assignments#destroy
      card_assigned_users GET    /cards/:id/assigned-users(.:format)                                                      cards#assigned_users
         card_doing_users GET    /cards/:id/doing-users(.:format)                                                         cards#doing_users
                card_tags GET    /cards/:id/tags(.:format)                                                                cards#tags
card_positions_update_all PATCH  /card-positions(.:format)                                                                card_positions#update_all
                     tags GET    /tags(.:format)                                                                          tags#index
                          POST   /tags(.:format)                                                                          tags#create
                      tag GET    /tags/:id(.:format)                                                                      tags#show
                          PATCH  /tags/:id(.:format)                                                                      tags#update
                          PUT    /tags/:id(.:format)                                                                      tags#update
                          DELETE /tags/:id(.:format)                                                                      tags#destroy
              attachments POST   /attachments(.:format)                                                                   attachments#create
               attachment DELETE /attachments/:id(.:format)                                                               attachments#destroy
                tag_cards GET    /tags/:id/cards(.:format)                                                                tags#cards
       user_created_cards GET    /users/:id/created-cards(.:format)                                                       users#created_cards
      user_assigned_cards GET    /users/:id/assigned-cards(.:format)                                                      users#assigned_cards
         user_doing_cards GET    /users/:id/doing-cards(.:format)                                                         users#doing_cards
     user_completed_cards GET    /users/:id/completed-cards(.:format)                                                     users#completed_cards
       rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
       rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
     rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create
```


