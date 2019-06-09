# AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA PORRA
def ingredient_search(full_ingredient_string)
  arr = full_ingredient_string.text.split(' ')

  alpha = ('A'..'Z').to_a

  conditionals!(arr)

  arr.shift until alpha.include? arr.first[0]
  arr.join(' ')
end

def conditionals!(arr)
  # p arr

  arr[1] = arr[1].capitalize if arr[1] == 'squeezed'
  arr[0] = arr[0].capitalize if arr[0] == 'salt' || arr[0] == 'flamed'
  arr[2] = 'Ketchup' if arr.last == 'ml'

  arr
end

system 'clear'
puts 'Cleaning records'

Cocktail.destroy_all
puts "Cocktails: #{Cocktail.count}"

Ingredient.destroy_all
puts "Ingredients: #{Ingredient.count}"

Dose.destroy_all
puts "Doses: #{Dose.count}"

puts '-' * 100

puts 'Started the Seed'

puts 'Will attempt to scrape https://www.socialandcocktail.co.uk/top-100-cocktails/'

puts '-' * 100

puts 'Looking for Cocktails:'

html_file = open('https://www.socialandcocktail.co.uk/top-100-cocktails/').read
html_doc = Nokogiri::HTML(html_file)

html_doc.search('.recipe_summary h3').each do |cocktail|
  cocktail_name = cocktail.text.strip
  new_cocktail = Cocktail.new(name: cocktail_name)
  if new_cocktail.valid?
    new_cocktail.save
    puts "#{Cocktail.count}: #{new_cocktail.name}"
  else
    puts '---------------------- Something went wrong --------------------'
    puts "                    #{new_cocktail.name}                    "
    puts "                    #{new_cocktail.errors.messages}              \n\n"
  end
end

puts '-' * 100

puts 'And Now for the Ingredients:'

html_doc.search('.content-appear p').each_with_index do |ingredient_tag, ingredient_index|
  next if ingredient_index.odd?

  # ingredient_tag.children.each_with_index { |s, i| puts "#{i}: #{s}" }
  # raise

  # ingredient_strings_arr = ingredient_tag.text.strip.split(/[\d+\/]+/)
  # ingredient_strings_arr.reject! { |string| string == ' ' }
  # ingredient_strings_arr.reject! { |string| string == '' }
  assholes = [' `', ' ml', ' ml ']

  ingredient_strings_arr = ingredient_tag.children

  ingredient_strings_arr.each_with_index do |ingredient_string, i|
    next if assholes.include?(ingredient_string) || i.odd?

    ingredient_string.capitalize if ingredient_string == ' squeezed lemon'

    new_name = ingredient_search(ingredient_string)
    new_ingredient = Ingredient.new(name: new_name)
    if new_ingredient.save
      puts "#{Ingredient.count}: #{new_ingredient.name}"
    else
      puts '---------------------- Something went wrong --------------------'
      puts "                    #{new_ingredient.name}                    "
      puts "               #{new_ingredient.errors.messages}               \n\n"
    end
  end
end

puts '-' * 100

puts 'Generating 12 Random Doses for each Cocktail'

Cocktail.all.each do |cocktail|
  measures = [
    'cups',
    'oz',
    'tea spoons',
    '1/2 cup',
    '1/4 cup',
    'ml',
    'slices',
    'pieces'
  ]
  12.times do
    ammount = "#{rand(1..8)} #{measures.sample}"
    dose = Dose.new(
      cocktail: cocktail,
      ingredient: Ingredient.all.sample,
      description: ammount
    )

    if dose.save
      puts "#{Dose.count}: #{dose.cocktail.name} - #{dose.description} of #{dose.ingredient.name}"
    else
      puts '---------------------- Something went wrong --------------------'
      puts "                    #{dose.ingredient}                    "
      puts "                    #{dose.errors.messages}                    \n\n"
    end
  end
end

puts 'Ended!'

puts '-' * 100

puts 'And you now are the proud owner of: '
puts "#{Cocktail.count} cocktails,"
puts "#{Ingredient.count} ingredients,"
puts "#{Dose.count} different doses!"
