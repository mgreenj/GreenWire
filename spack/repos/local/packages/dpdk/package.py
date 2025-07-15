from spack.package import *


class Dpdk(MesonPackage):
    """ DPDK: Data Plane Development Kit. """

    homepage = "https://github.com/DPDK/dpdk"
    url = "https://github.com/DPDK/dpdk/archive/v23.03.tar.gz"
    git = "https://github.com/DPDK/dpdk.git"

    maintainers = ['mgreenj']

    version("25.03", sha256="6a40a731328286ebd79685b18ffa5992e6b770c13843d65fd0d1157cfccff63d")
    version("23.03", sha256="922067ad6b0a0daf934adf833fcdc29c5154837a4a1f6dc0ffbdcf6dab9edef5")


    depends_on("cmake@3.16.9", type="build")
    depends_on("ninja", type="build")
    depends_on("py-pyelftools")
    depends_on("numactl")
    depends_on("libpcap")

    def meson_args(self):
        return [
            '-Dc_args=-Wno-pedantic'
        ]