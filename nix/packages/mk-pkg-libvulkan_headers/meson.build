# https://mesonbuild.com/External-Project-module.html

project('libplacebo', 'c')

mod = import('unstable-external_project')

p = mod.add_project('configure',
    configure_options : [
        '-DCMAKE_BUILD_TYPE=Release'
    ],
    verbose: true,
)

libvulkan_headers_dep = p.dependency('libvulkan_headers')
meson.override_dependency('libvulkan_headers', libvulkan_headers_dep)
