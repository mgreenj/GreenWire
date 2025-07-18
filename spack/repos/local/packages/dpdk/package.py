from spack.package import *


class Dpdk(MesonPackage):
    """ DPDK: Data Plane Development Kit. """

    homepage = "https://github.com/DPDK/dpdk"
    url = "https://github.com/DPDK/dpdk/archive/v23.03.tar.gz"
    git = "https://github.com/DPDK/dpdk.git"

    maintainers = ['mgreenj']

    version("25.03", sha256="6a40a731328286ebd79685b18ffa5992e6b770c13843d65fd0d1157cfccff63d")
    version("23.03", sha256="8a8fa67941b1e0d428937f9068f401457e4e4fd576031479450da065385b332c")


    depends_on("cmake@3.16.9", type="build")
    depends_on("ninja", type="build")
    depends_on("py-pyelftools")
    depends_on("numactl")
    depends_on("libpcap")
    depends_on("libbsd")
    depends_on("libmd")

    def setup_build_environment(self, env):
        env.append_flags('LDFLAGS', '-L{0} -lmd'.format(self.spec['libmd'].prefix.lib))
        env.append_flags('LDFLAGS', '-L{0} -lbsd'.format(self.spec['libbsd'].prefix.lib))
        env.prepend_path('PKG_CONFIG_PATH', self.spec['libmd'].prefix.lib.pkgconfig)
        env.prepend_path('PKG_CONFIG_PATH', self.spec['libbsd'].prefix.lib.pkgconfig)

    def meson_args(self):
        return ['-Dc_args=-Wno-pedantic']