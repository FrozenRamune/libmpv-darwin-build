# https://mesonbuild.com/External-Project-module.html

project('libplacebo', 'c')

mod = import('unstable-external_project')

p = mod.add_project('configure',
    configure_options : [
        '-DCMAKE_BUILD_TYPE=Release',
        '-DSHADERC_SKIP_COPYRIGHT_CHECK=True',
        '-DSHADERC_SKIP_TESTS=True'
    ],
    verbose: true,
)

libshaderc_dep = p.dependency('libshaderc')
meson.override_dependency('libplacebo', libshaderc_dep)
