# Builds the specified version of ØMQ.
#
# Parameters:
#
#     1 - The version of ØMQ to install, in the form "vx.y.z"
#     2 - The directory to install ØMQ to
#     3 - The directory to move the installed ØMQ to
build_zeromq() {
    local version=$1
    local install_dir=$2
    local dest_dir=$3

    case $zeromq_version in
    v2.2.0)
        wget http://download.zeromq.org/zeromq-2.2.0.tar.gz
        tar -xf zeromq-2.2.0.tar.gz
        cd zeromq-2.2.0
        ;;
    v3*)
        git clone https://github.com/zeromq/zeromq3-x
        cd zeromq3-x
        git checkout "tags/${version}"
        ;;
    v4*)
        git clone https://github.com/zeromq/zeromq4-x
        cd zeromq4-x
        git checkout "tags/${version}"
        ;;
    esac

    if test -d $install_dir
    then
        sudo rm -rf $install_dir
    fi

    ./autogen.sh
    ./configure --prefix=$install_dir
    make -j 8
    sudo make install

    cd .. # cd zeromq...

    if test -d $dest_dir
    then
        rm -rf $dest_dir
    fi

    cp -r $install_dir $dest_dir
}

zeromq_versions=(
    "v2.2.0"
    "v3.1.0"
    "v3.2.0"
    "v3.2.1"
    "v3.2.2"
    "v3.2.3"
    "v3.2.4"
    "v4.0.0"
    "v4.0.1"
    "v4.0.2"
    "v4.0.3"
    "v4.0.4"
)
zeromq_install_dir=/tmp/zeromq
zeromq_base_dest_dir=/vagrant/zeromq

pushd /tmp

for zeromq_version in "${zeromq_versions[@]}"
do
    build_zeromq \
        $zeromq_version \
        $zeromq_install_dir \
        "${zeromq_base_dest_dir}/zeromq-${zeromq_version}"
done

popd # pushd /tmp
