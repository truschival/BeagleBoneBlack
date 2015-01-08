# BeagleBoneBlack
Beagle Bone Black for Buildroot as external package tree, mainly a demo-package tree to play around with Buildroot.
See http://buildroot.uclibc.org/downloads/manual/manual.html#customize 

Currently the libtransmog and transmogclient (see my other public github repos) are included. 
They should provide an example on how to work with it with custom packages 
and how to distribute package builds as binaries. (_a non-buildroot standard extension_)


The configuration is based on the `beaglebone_defconfig` form buildroot upstream. 
To speed up build-time and especially git-clone download time some substational are made.
`bbb_defconfig` uses a local linux-source tree, a locally installed external toolchain. 

### Build Pre-requisites if you use bbb_config:

- buildroot installation (`git clone git://git.buildroot.net/buildroot` )
- linaro toolchain installed in `/opt/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/`
- a Texas-Instruments linux repository clone in `/usr/src/linux`

##### Get the linaro toolchain
  ````
  cd /opt
  wget http://releases.linaro.org/14.09/components/toolchain/binaries/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux.tar.xz
  tar -xf gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux.tar.xz
  ````

#####  Setup the TI-Linux source tree
  ```
  cd /usr/src/linux
  git remote add ti git://git.ti.com/ti-linux-kernel/ti-linux-kernel.git` 
  git fetch ti
  git checkout -B ti-v3.12 7f280334068b7c875ade51f8f3921ab311f0c824
  ``` 

### How to build
To use this repository content of this repository I recommend doing a complete out-of-tree build.

```
make BR2_EXTERNAL=<local_clone_of_this_repo> -C<Buildroot_installation_dir> O=<Build_tree> bbb_defconfig 
cd <Build_tree> 
make menuconfig (optional)
make
```



