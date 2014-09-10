fs = require 'fs'
zlib = require 'zlib'
tar = require 'tar'

args = process.argv.splice(2)

console.log "> " + process.argv.join ' '

switch args[0]
  when 'ungzip'
    throw new Error 'No file provided' unless args[1]
    throw new Error "Does not exist: #{args[1]}" unless fs.existsSync args[1]

    target = args[1].replace /\.\w+$/, ''

    fs.createReadStream args[1]
    .pipe zlib.createGunzip()
    .pipe tar.Extract path: target
    .on 'done', () ->
      console.log "Extracted to: #{target}"

  else
    console.log 'Hello from base!'
