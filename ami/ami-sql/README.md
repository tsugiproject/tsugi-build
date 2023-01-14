Transition for user\_data.sh files
---------------------------------

This folder contains scripts to help if a legacy `user_data.sh` file file
the `ami-sql` era is used in a `tsugi-build` build.

The `user_data.sh` process in `tsugi-build` differs from `ami-sql` in the following ways:

* In `tsugi-build` the install is in `/root` and not `/home/ubuntu`

* In `tsugi-build`, the script that "finishes things up" is `tsugi-prod-configure.sh`

Here are some sample old and new `user_data.sh` files.

Old Pattern
-----------

    cat << EOF > /home/ubuntu/tsugi_env.sh

    export MAIN_REPO=https://www.github.com/learnxp/test-client-web.git 
    ...
    EOF

    source /home/ubuntu/tsugi_env.sh

    # Get the latest
    cd /home/ubuntu/ami-sql
    git pull

    source /home/ubuntu/ami-sql/post-ami.sh

New Pattern
-----------

    cat << EOF > /root/ubuntu-env.sh

    export MAIN_REPO=https://github.com/tsugicloud/website.git
    ...
    EOF

    source /root/ubuntu-env.sh

    # Get the latest build scripts
    cd /root/tsugi-build
    git pull

    bash /usr/local/bin/tsugi-prod-configure.sh return

Solution
--------

We build a `post-ami.sh` script here that patches things up.




