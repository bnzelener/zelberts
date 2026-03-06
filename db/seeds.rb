# Clear existing events to re-seed cleanly
Event.destroy_all

Event.create!(
  name: "Welcome Drinks",
  date: Date.new(2026, 9, 11),
  time: "5:00 PM",
  location: "A Lodge Rock Garden",
  address: "https://www.rockgardenlyons.com/",
  description: "Join us the evening before for a casual gathering to kick off the weekend.",
  sort_order: 1
)

Event.create!(
  name: "Ceremony + Reception",
  date: Date.new(2026, 9, 12),
  time: "4:00 PM - 10:00 PM",
  location: "The Lyons Farmette",
  address: "4121 Ute Hwy, Lyons, CO 80540",
  description: "Please join us as we say \"I do,\" followed by dinner, toasts, and dancing.",
  sort_order: 2
)

Event.create!(
  name: "After Party",
  date: Date.new(2026, 9, 12),
  time: "10:00 PM - 1:00 AM",
  location: "MainStage Brewing",
  address: "450 Main Street, Lyons, CO 80540",
  description: "Keep the celebration going at one of our favorite local spots.",
  sort_order: 3
)

puts "Seeded #{Event.count} events"
