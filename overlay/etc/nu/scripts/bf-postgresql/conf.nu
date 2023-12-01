use bf

# Generate data configuration files
export def generate [] {
    bf esh template (bf env PG_DATA_CONF)
    bf esh template (bf env PG_DATA_HBA_CONF)
}
