# https://mesonbuild.com/External-Project-module.html

project('libplacebo', 'c')

mod = import('unstable-external_project')

p = mod.add_project('configure',
    configure_options : [
        '-DCMAKE_BUILD_TYPE=Release'
        '-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON'
        '-DSYSCONFDIR=/usr/local/etc'
    ],
    verbose: true,
)

libvulkan_loader_dep = p.dependency('libvulkan_loader')
meson.override_dependency('libvulkan_loader', libvulkan_loader_dep)
