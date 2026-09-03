# Copy schema/CSV (and optionally web) next to the binary, matching the old CMake copy step.
CHARGEPILE_ROOT = $$PWD/..

unix {
    SYNC = $$shell_quote($$CHARGEPILE_ROOT/scripts/sync_runtime_assets.sh)
    ROOT = $$shell_quote($$CHARGEPILE_ROOT)
    DEST = $$shell_quote($$OUT_PWD)
    !isEmpty(CHARGEPILE_COPY_WEB) {
        QMAKE_POST_LINK += bash $$SYNC $$ROOT $$DEST web
    } else {
        QMAKE_POST_LINK += bash $$SYNC $$ROOT $$DEST
    }
}
