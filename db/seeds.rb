# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
def ingredient_search(full_ingredient_string)
  arr = full_ingredient_string.split(' ')

  alpha = ('A'..'Z').to_a

  arr.shift until alpha.include? arr.first[0]
  arr.join(' ')
end

puts 'Cleaning records'

Cocktail.destroy_all
puts "Cocktails: #{Cocktail.count}"

Ingredient.destroy_all
puts "Ingredients: #{Ingredient.count}"

Dose.destroy_all
puts "Doses: #{Dose.count}"

puts '-' * 100

puts 'Started the Seed'

puts 'Will attempt to scrape https://gruetwinery.com/7/cocktail-recipes'

puts '-' * 100

puts 'Looking for Cocktails:'

html_file = open('https://gruetwinery.com/7/cocktail-recipes').read
html_doc = Nokogiri::HTML(html_file)

html_doc.search('.cocktail h3').each do |cocktail|
  cocktail_name = cocktail.text.strip
  new_cocktail = Cocktail.new(name: cocktail_name)
  if new_cocktail.valid?
    new_cocktail.save
    puts "#{Cocktail.count}: #{new_cocktail.name}"
  else
    puts 'Something went wrong'
  end
end

puts '-' * 100

puts 'And Now for the Ingredients:'

html_doc.search('.cocktail li').each do |ingredient_tag|
  ingredient_string = ingredient_tag.text.strip
  new_name = ingredient_search(ingredient_string)
  new_ingredient = Ingredient.new(name: new_name)
  if new_ingredient.save
    puts "#{Ingredient.count}: #{new_ingredient.name}"
  else
    puts '----------- Something went wrong ----------'
  end
end

puts '-' * 100

puts 'Generating Random Doses'

Cocktail.all.each do |cocktail|
  3.times do
    measures = [
      'cups',
      'oz',
      'tea spoons',
      'soup spoons',
      '1/2 cup',
      '1/4 cup'
    ]
    ammount = "#{rand(1..8)} #{measures.sample}"
    dose = Dose.new(
      cocktail: cocktail,
      ingredient: Ingredient.all.sample,
      description: ammount
    )

    if dose.save
      puts "#{Dose.count}: #{dose.cocktail.name} - #{dose.description} of #{dose.ingredient.name}"
    else
      puts '----------- Something went wrong ----------'
    end
  end
end

puts 'Ended!'

puts '-' * 100

puts 'And you now are the proud owner of: '
puts "#{Cocktail.count} cocktails,"
puts "#{Ingredient.count} ingredients,"
puts "#{Dose.count} different doses!"
