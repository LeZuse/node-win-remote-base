fs = require 'fs'
fstream = require 'fstream'
zlib = require 'zlib'
tar = require 'tar'

args = process.argv.slice(2)

console.log "> " + process.argv.join ' '

switch args[0]
  when 'ungzip'
    throw new Error 'No filename provided' unless args[1]
    throw new Error "Does not exist: #{args[1]}" unless fs.existsSync args[1]

    target = args[1].replace /\.\w+$/, ''

    fs.createReadStream args[1]
    .pipe zlib.createGunzip()
    .pipe tar.Extract path: target
    .on 'done', ->
      console.log "Extracted to: #{target}"

  when 'gzip'
    throw new Error 'No dir name provided' unless args[1]
    throw new Error "Does not exist: #{args[1]}" unless fs.existsSync args[1]# and fs.statSync(args[1]).isDirectory()

    archive = args[1] + '.tgz'

    # BUG: https://github.com/npm/node-tar/issues/7#issuecomment-17572926
    fixupDirs = (entry) ->
      # Make sure readable directories have execute permission
      if entry.props.type is 'Directory'
        entry.props.mode |= (entry.props.mode >>> 2) & 0o111
      true

    fstream.Reader
      path: args[1]
      type: 'Directory'
      filter: fixupDirs
    .pipe tar.Pack
      noProprietary: true
    .pipe zlib.createGzip()
    .pipe fs.createWriteStream archive
    .on 'done', ->
      console.log "Created: #{archive}"

  else
    console.log 'Hello from base!'
