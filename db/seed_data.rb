# frozen_string_literal: true

module SeedData
  def self.drivers
    [
      { name: "Andy Nguyen",        email: "Andynugy@gmail.com",        phone: "925-320-1196" },
      { name: "Anna Wah",           email: "anna.l.wah@gmail.com",      phone: "510-499-7792" },
      { name: "Beth Brown",         email: "beth@kidshideout.net",      phone: "925-482-7956" },
      { name: "Bill Kidd",          email: "skidd3428@comcast.net",     phone: "925-297-9032" },
      { name: "Craig Isaacs",       email: "craig@isaacs.org",          phone: "925-360-8055" },
      { name: "Cynthia Curcuro",    email: "cynthiacurcuro@gmail.com",  phone: "415-706-2870" },
      { name: "Deborah Sandberg",   email: "deborahdroker01@gmail.com", phone: "925-699-9470" },
      { name: "Elena Toohey",       email: "etoohey@sbcglobal.net",     phone: "925-989-4348" },
      { name: "Geoff Bellenger",    email: "gbellenger@comcast.net",    phone: "510-504-6064" },
      { name: "Jeanne Hughes",      email: "Jeanne@jhughes.net",        phone: "858-337-7620" },
      { name: "Jim Holt",           email: "jholtf@pacbell.net",        phone: "925-876-0625" },
      { name: "John Raskin",        email: "engager115@yahoo.com",      phone: "925-878-8428" },
      { name: "Laura-Kate Rurka",   email: "lkrurka@lamorindavillage.org", phone: "415-203-3019" },
      { name: "Leslie Whitney",     email: "Lesliewhitney25@gmail.com", phone: "510-388-5794" },
      { name: "Mark Danforth",      email: "markdanforth@comcast.net",  phone: "415-225-4155" },
      { name: "Mike Marion",        email: "bilbeaus@yahoo.com",        phone: "925-817-9907" },
      { name: "Paul Gifford",       email: "pdg30t@gmail.com",          phone: "510-846-0277" },
      { name: "Sean Arbabi",        email: "arbabi1@me.com",            phone: "925-683-9498" },
      { name: "Steve Layshock",     email: "slayshock3698@gmail.com",   phone: "925-278-4657" },
      { name: "Suzy Pak",           email: "suzypak@gmail.com",         phone: "925-899-0990" },
      { name: "Tim Kean",           email: "timkean@comcast.net",       phone: "925-708-4734" },
      { name: "Vanessa Mancebo",    email: "vjmancebo@comcast.net",     phone: "925-286-8329" }
    ].map do |d|
      d.merge(active: true)
    end
  end
end
