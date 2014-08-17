RE_PARTIAL = /.*\.(coffee|js)$/
 
targets = Dir.glob("(app|test)/**/*")

targets.each do |file|
  if file=~RE_PARTIAL
    p file
    rd = IO.read file
    IO.write file, "'use strict'\n" + rd
  end
end