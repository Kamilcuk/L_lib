L_argparse \
    -- call=subparser dest=command \
    { \
        name=clone \
        -- repo_url \
    } \
    { \
        name=remote \
        description="Manage remote repositories" \
        -- call=subparser dest=remote_command \
        { \
            name=add \
            -- remote_name \
            -- url \
        } \
        { \
            name=remove \
            -- remote_name \
        } \
    } \
    ---- "$@"

case "$command" in
    clone)
        echo "Cloning from $repo_url"
        ;;
    remote)
        case "$remote_command" in
            add)
                echo "Adding remote '$remote_name' with URL '$url'"
                ;;
            remove)
                echo "Removing remote '$remote_name'"
                ;;
        esac
        ;;
esac
