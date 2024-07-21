# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Apple = User.create({
                      email: 'a@a.com',
                      username: 'apple',
                      password: 'simplify1!',
                      details: '',
                    })
Banana = User.create({
                       email: 'b@b.com',
                       username: 'banana',
                       password: 'simplify1!',
                       details: '',
                     })
Cherry = User.create({
                       email: 'c@c.com',
                       username: 'cherry',
                       password: 'simplify1!',
                       details: '',
                     })
Evil = User.create({
                     email: 'e@e.com',
                     username: 'evil',
                     password: 'simplify1!',
                     details: '',
                   })
Friendship.create({
                    sender_id: Apple.id,
                    receiver_id: Banana.id,
                    confirmed: true
                  })