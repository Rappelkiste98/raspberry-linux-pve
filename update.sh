#! /bin/bash -e
work_dir=$(pwd)

echo "Script Working Dir: $work_dir"
# Update Main Repo
echo "\n============================ ! Update Repository 'raspberry-linux-pve' ! ============================\n"
git fetch --all --tags

read -p "Enter newest Branch: " pve_branch
git checkout $pve_branch
git pull

# Update Submodule RaspberryPi Linux
echo "\n============================ ! Update Submodule 'linux' ! ============================\n"
git submodule update --depth 1

cd $work_dir/linux && git fetch --all --tags --depth 1
git reset --hard && git clean -d -f

read -p "Enter newest 'linux' Branch: " linux_branch
git checkout $linux_branch && git pull -f

read -p "Enter newest 'linux' Tag: " linux_tag
git checkout tags/$linux_tag
git reset --hard && git clean -d -f

# Update Submodule OpenZFS
echo "\n============================ ! Update Submodule 'linux' ! ============================\n"
git submodule update --depth 1

cd $work_dir/zfs && git fetch --all --tags --depth 1
git reset --hard && git clean -d -f

git checkout master && git pull -f

read -p "Enter newest 'zfs' Tag: " zfs_tag
git checkout tags/$zfs_tag
git reset --hard && git clean -d -f

cd $work_dir/
while true; do
        read -p "Do you wish to commit the Update? (y/n) " yn
        case $yn in
                [Yy]* ) git commit -a -m 'Update Dependencies'; break;;
                [Nn]* ) break;;
                * ) echo "Please answer yes or no.";;
        esac
done
echo "\n============================ ! Successfully updated ! ============================\n"
