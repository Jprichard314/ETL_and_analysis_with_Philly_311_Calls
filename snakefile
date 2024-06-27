import snakemake

rule all:
    input:
        "data/db/db.db"

# -------------------------
# Import Data
# -------------------------

rule import_data__three_one_one:
    output:
        "data/raw/data_calls.parquet"
    run:
        import polars
        import polars.datatypes

        # Base python libraries
        from datetime import datetime

        # Custom Code
        from src.pyUtils.apis import phillyOpenData

        query = phillyOpenData.writeDateTimeFilter(
            end_date = datetime.today().date().strftime('%m/%d/%Y'),
            interval = 24,
            base_query = "SELECT * FROM public_cases_fc",
            date_field = 'requested_datetime'
        )

        data = (
                    phillyOpenData.cartoApi(query)
                        .queryDataframe(infer_schema_length = 1000,
                                        schema_overrides = {
                                            'zipcode': polars.datatypes.String,
                                            'requested_datetime':polars.datatypes.Datetime,
                                            'updated_datetime':polars.datatypes.Datetime,
                                            'expected_datetime':polars.datatypes.Datetime,
                                            'closed_datetime':polars.datatypes.Datetime,
                                        })
                )
        
        data.write_parquet(f'{output}')

# -------------------------
# Validate the Data
# -------------------------

# -------------------------
# DBT
# -------------------------
rule run_dbt:
    output:
        "data/db/db.db"
    input:
        "data/raw/data_calls.parquet"
    shell:
        """
        dbt run
        """