#!/bin/sh
set -e

prefix="CONFIG_"
config=`env | grep $prefix`

# config_path=${config_path:-/var/www/html/}
config_path=${config_path:-.}

js_files=`find ${config_path} -iname 'main*.js'`

variables=""

for i in $config; do
    if echo $i | grep -Eq "^${prefix}"; then
        var=${i%%=*}
        name=${var#*CONFIG_}
        value=${i#*=};
        export "${name}"="$value"

        variables="\$${name}, ${variables}"
    fi
done

if [ -n "$variables" ]; then
    echo "The following variables will be substituted:"

    # for variable in `echo $variables | tr ',' '\n'`; do
    for variable in `echo $variables | sed 's/,\s*/\n/g'`; do
        echo "- ${variable}"
    done

    echo "In the following files:"
    for file in $js_files; do
        echo "- $file"
        cat $file > "${file}.tpl"
        envsubst "$variables" <"${file}.tpl" >"${file}.final"
        rm "${file}.tpl"
        cp "${file}" "${file}.original"
        # mv "${file}.final" "${file}"
    done
fi

echo "Substitution done."
