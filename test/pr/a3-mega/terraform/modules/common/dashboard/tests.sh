. ./test/helpers.sh

a3-mega::terraform::dashboard::src_dir () {
    echo "${PWD}/a3-mega/terraform/modules/common/dashboard"
}

a3-mega::terraform::dashboard::input_dir () {
    echo "${PWD}/test/pr/a3-mega/terraform/modules/common/dashboard/input"
}

a3-mega::terraform::dashboard::output_dir () {
    echo "${PWD}/test/pr/a3-mega/terraform/modules/common/dashboard/output"
}

test::a3-mega::terraform::dashboard () {
    EXPECT_SUCCEED helpers::terraform_init "$(a3-mega::terraform::dashboard::src_dir)"
}

test::a3-mega::terraform::dashboard::disable_all_widgets () {
    local -r tfvars=$(mktemp)
    helpers::append_tfvars "$(a3-mega::terraform::dashboard::input_dir)/disable.tfvars" mig >"${tfvars}"

    local -r tfplan=$(mktemp)
    EXPECT_SUCCEED helpers::terraform_plan \
        "$(a3-mega::terraform::dashboard::src_dir)" \
        "${tfvars}" \
        "${tfplan}"

    local -r tfshow=$(mktemp)
    helpers::terraform_show "$(a3-mega::terraform::dashboard::src_dir)" "${tfplan}" >"${tfshow}"
    EXPECT_SUCCEED helpers::json_contains \
        "$(a3-mega::terraform::dashboard::output_dir)/modules.json" \
        "${tfshow}"
    EXPECT_SUCCEED helpers::json_omits \
        "$(a3-mega::terraform::dashboard::output_dir)/data.json" \
        "${tfshow}"
}

test::a3-mega::terraform::dashboard::enable_all_widgets () {
    local -r tfvars=$(mktemp)
    helpers::append_tfvars "$(a3-mega::terraform::dashboard::input_dir)/enable.tfvars" mig >"${tfvars}"

    local -r tfplan=$(mktemp)
    EXPECT_SUCCEED helpers::terraform_plan \
        "$(a3-mega::terraform::dashboard::src_dir)" \
        "${tfvars}" \
        "${tfplan}"

    local -r tfshow=$(mktemp)
    helpers::terraform_show "$(a3-mega::terraform::dashboard::src_dir)" "${tfplan}" >"${tfshow}"
    EXPECT_SUCCEED helpers::json_contains \
        "$(a3-mega::terraform::dashboard::output_dir)/modules.json" \
        "${tfshow}"
    EXPECT_SUCCEED helpers::json_contains \
        "$(a3-mega::terraform::dashboard::output_dir)/data.json" \
        "${tfshow}"
}
