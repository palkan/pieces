#!/bin/bash
for file in `find -iname app/styles/pieces/*.sass`; do
  f="${file##*styles/}"
  cp "$file" "./pieces-rails/app/assets/stylesheets/${f%.sass}.css.sass"
done

cp "./app/styles/pieces.sass" "./pieces-rails/app/assets/stylesheets/pieces.css.sass" 
echo "done"