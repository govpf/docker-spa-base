#!/bin/bash
set -e

prefix="CONFIG_"
config=`env | grep $prefix || true`

js_basepath=${js_basepath:-/var/www/html/}

js_files=`find ${js_basepath} -iname 'main*.js'`

variables=""

for i in $config; do
    if echo $i | grep -Eq "^${prefix}"; then
        var=${i%%=*}
        name=${var#*CONFIG_}
        value=${i#*=};
        export ${name}="$(echo $value)"
        # TODO debug, only works w/ Bash
        echo "${!name}"

        variables="\$${name}, ${variables}"
    fi
done

if [ -n "$variables" ]; then
    echo "The following variables will be substituted:"

    for variable in `echo $variables | sed 's/,\s*/\n/g'`; do
        echo "- ${variable}"
    done

    js_files="$(find ${js_basepath} -iname main*.js)"

    if [ -n "${js_files}" ]; then
        # perms=`ls -l ${js_basepath}/main*.js | awk '{  $1":"$2 }' | head -1`
        # owner=`echo $perms | cut -d':' -f1`
        # group=`echo $perms | cut -d':' -f2`
        js_file="$(echo $js_files | head -1)"
        owner=$(stat -c '%u' "${js_file}")
        group=$(stat -c '%g' "${js_file}")

        echo "In the following files:"
        for file in $js_files; do
            echo "- $file"
            filename=`basename "$file"`
            dir_path=`dirname "$file"`
            cat $file > "${filename}.tpl"
            envsubst "$variables" <"${filename}.tpl" >"${dir_path}/${filename}.final"
            rm "${filename}.tpl"
            cp "${file}" "/tmp/${filename}.original"
            chown $owner:$group "${dir_path}/${filename}.final"
            mv "${dir_path}/${filename}.final" "${dir_path}/${filename}"
            echo "${filename} replaced."
        done
    else
        echo "No main*.js files found."
    fi
    echo "Substitution done."
else
    echo "No variable to substitute."
fi
