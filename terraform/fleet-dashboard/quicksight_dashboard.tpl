{
    "AwsAccountId":"${AWS_ACCOUNT_ID}",
    "DashboardId": "${QS_DASHBOARD_NAME}",
    "Name": "${QS_DASHBOARD_NAME}",
    "Definition": {
        "DataSetIdentifierDeclarations": [
            {
                "Identifier": "${UPGRADE_INSIGHTS_DATASET}",
                "DataSetArn": "arn:aws:quicksight:${AWS_REGION}:${AWS_ACCOUNT_ID}:dataset/${UPGRADE_INSIGHTS_DATASET}"
            },
            {
                "Identifier": "${CLUSTERS_DATA_DATASET}",
                "DataSetArn": "arn:aws:quicksight:${AWS_REGION}:${AWS_ACCOUNT_ID}:dataset/${CLUSTERS_DATA_DATASET}"
            },
            {
                "Identifier": "${SUPPORT_DATA_DATASET}",
                "DataSetArn": "arn:aws:quicksight:${AWS_REGION}:${AWS_ACCOUNT_ID}:dataset/${SUPPORT_DATA_DATASET}"
            },
            {
                "Identifier": "${CLUSTERS_DETAILS_DATASET}",
                "DataSetArn": "arn:aws:quicksight:${AWS_REGION}:${AWS_ACCOUNT_ID}:dataset/${CLUSTERS_DETAILS_DATASET}"
            },
            {
                "Identifier": "${KUBERNETES_RELEASE_CALENDAR}",
                "DataSetArn": "arn:aws:quicksight:${AWS_REGION}:${AWS_ACCOUNT_ID}:dataset/${KUBERNETES_RELEASE_CALENDAR}"
            },
            {
                "Identifier": "${CLUSTERS_SUMMARY_DATASET}",
                "DataSetArn": "arn:aws:quicksight:${AWS_REGION}:${AWS_ACCOUNT_ID}:dataset/${CLUSTERS_SUMMARY_DATASET}"
            },
            {
                "Identifier": "${ARGO_PROJECTS_DATASET}",
                "DataSetArn": "arn:aws:quicksight:${AWS_REGION}:${AWS_ACCOUNT_ID}:dataset/${ARGO_PROJECTS_DATASET}"
            }
        ],
        "Sheets": [
            {
                "SheetId": "bdb12279-a3ba-4ebc-b177-56d797ad7f3d_bbd4e626-2b1f-40f6-a6c7-c2acf7f1f896",
                "Name": "EKS Fleet View",
                "FilterControls": [
                    {
                        "Dropdown": {
                            "FilterControlId": "037173c3-f0cb-441f-93f5-57bbd154a4aa",
                            "Title": "Account Id",
                            "SourceFilterId": "b2caec24-6838-4ff1-b6ab-6379fa41c1d9",
                            "DisplayOptions": {
                                "SelectAllOptions": {
                                    "Visibility": "VISIBLE"
                                },
                                "TitleOptions": {
                                    "Visibility": "VISIBLE",
                                    "FontConfiguration": {
                                        "FontSize": {
                                            "Relative": "MEDIUM"
                                        }
                                    }
                                },
                                "InfoIconLabelOptions": {
                                    "Visibility": "HIDDEN"
                                }
                            },
                            "Type": "MULTI_SELECT"
                        }
                    },
                    {
                        "Dropdown": {
                            "FilterControlId": "806c3717-09e9-4c08-bc3f-e664b0efb48d",
                            "Title": "Region",
                            "SourceFilterId": "c479d2a1-9f37-4ab3-855b-c902b9fab861",
                            "DisplayOptions": {
                                "SelectAllOptions": {
                                    "Visibility": "VISIBLE"
                                },
                                "TitleOptions": {
                                    "Visibility": "VISIBLE",
                                    "FontConfiguration": {
                                        "FontSize": {
                                            "Relative": "MEDIUM"
                                        }
                                    }
                                },
                                "InfoIconLabelOptions": {
                                    "Visibility": "HIDDEN"
                                }
                            },
                            "Type": "MULTI_SELECT"
                        }
                    },
                    {
                        "Dropdown": {
                            "FilterControlId": "eedbf19d-8c30-424f-8479-4581d6ce96ff",
                            "Title": "Cluster Name",
                            "SourceFilterId": "eb2717c1-ea04-4039-9cdd-65935bb59e46",
                            "DisplayOptions": {
                                "SelectAllOptions": {
                                    "Visibility": "VISIBLE"
                                },
                                "TitleOptions": {
                                    "Visibility": "VISIBLE",
                                    "FontConfiguration": {
                                        "FontSize": {
                                            "Relative": "MEDIUM"
                                        }
                                    }
                                },
                                "InfoIconLabelOptions": {
                                    "Visibility": "HIDDEN"
                                }
                            },
                            "Type": "MULTI_SELECT"
                        }
                    },
                    {
                        "Dropdown": {
                            "FilterControlId": "9f63b22c-6d75-4559-87aa-3ad875b643dd",
                            "Title": "Cluster Version",
                            "SourceFilterId": "e18f6a58-8cb1-4bfa-be98-fc721aa2db84",
                            "DisplayOptions": {
                                "SelectAllOptions": {
                                    "Visibility": "VISIBLE"
                                },
                                "TitleOptions": {
                                    "Visibility": "VISIBLE",
                                    "FontConfiguration": {
                                        "FontSize": {
                                            "Relative": "MEDIUM"
                                        }
                                    }
                                }
                            },
                            "Type": "SINGLE_SELECT"
                        }
                    },
                    {
                        "Dropdown": {
                            "FilterControlId": "3ee97d72-e777-4b41-87af-fe3418f46c57",
                            "Title": "Support Status",
                            "SourceFilterId": "fe204e56-6701-49d4-91b9-9a42b5e40d31",
                            "DisplayOptions": {
                                "SelectAllOptions": {
                                    "Visibility": "VISIBLE"
                                },
                                "TitleOptions": {
                                    "Visibility": "VISIBLE",
                                    "FontConfiguration": {
                                        "FontSize": {
                                            "Relative": "MEDIUM"
                                        }
                                    }
                                },
                                "InfoIconLabelOptions": {
                                    "Visibility": "HIDDEN"
                                }
                            },
                            "Type": "MULTI_SELECT"
                        }
                    }
                ],
                "Visuals": [
                    {
                        "PieChartVisual": {
                            "VisualId": "bdb12279-a3ba-4ebc-b177-56d797ad7f3d_c07b4be0-f5ac-43e4-b3a2-a2ee57550175",
                            "Title": {
                                "Visibility": "VISIBLE",
                                "FormatText": {
                                    "RichText": "<visual-title>\n  <b>EKS Clusters per Account</b>\n</visual-title>"
                                }
                            },
                            "Subtitle": {
                                "Visibility": "VISIBLE"
                            },
                            "ChartConfiguration": {
                                "FieldWells": {
                                    "PieChartAggregatedFieldWells": {
                                        "Category": [
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${CLUSTERS_DATA_DATASET}-alias.Account Id.0.1717557653403",
                                                    "Column": {
                                                        "DataSetIdentifier": "${CLUSTERS_DATA_DATASET}",
                                                        "ColumnName": "Account Id"
                                                    }
                                                }
                                            }
                                        ],
                                        "Values": []
                                    }
                                },
                                "SortConfiguration": {
                                    "CategoryItemsLimit": {
                                        "OtherCategories": "INCLUDE"
                                    },
                                    "SmallMultiplesLimitConfiguration": {
                                        "OtherCategories": "INCLUDE"
                                    }
                                },
                                "DonutOptions": {
                                    "ArcOptions": {
                                        "ArcThickness": "MEDIUM"
                                    }
                                },
                                "CategoryLabelOptions": {
                                    "AxisLabelOptions": [
                                        {
                                            "CustomLabel": "Number of EKS Clusters per Account",
                                            "ApplyTo": {
                                                "FieldId": "${CLUSTERS_DATA_DATASET}-alias.Account Id.0.1717557653403",
                                                "Column": {
                                                    "DataSetIdentifier": "${CLUSTERS_DATA_DATASET}",
                                                    "ColumnName": "Account Id"
                                                }
                                            }
                                        }
                                    ]
                                },
                                "Legend": {
                                    "Width": "179px"
                                },
                                "DataLabels": {
                                    "Visibility": "VISIBLE",
                                    "Overlap": "DISABLE_OVERLAP"
                                },
                                "Tooltip": {
                                    "TooltipVisibility": "VISIBLE",
                                    "SelectedTooltipType": "DETAILED",
                                    "FieldBasedTooltip": {
                                        "AggregationVisibility": "HIDDEN",
                                        "TooltipTitleType": "PRIMARY_VALUE",
                                        "TooltipFields": [
                                            {
                                                "FieldTooltipItem": {
                                                    "FieldId": "${CLUSTERS_DATA_DATASET}-alias.Account Id.0.1717557653403",
                                                    "Visibility": "VISIBLE"
                                                }
                                            }
                                        ]
                                    }
                                }
                            },
                            "Actions": [],
                            "ColumnHierarchies": []
                        }
                    },
                    {
                        "PieChartVisual": {
                            "VisualId": "bdb12279-a3ba-4ebc-b177-56d797ad7f3d_476a235f-cbcf-40b4-8a16-d7fb30b8340b",
                            "Title": {
                                "Visibility": "VISIBLE",
                                "FormatText": {
                                    "RichText": "<visual-title>\n  <b>EKS Clusters per Region</b>\n</visual-title>"
                                }
                            },
                            "Subtitle": {
                                "Visibility": "VISIBLE"
                            },
                            "ChartConfiguration": {
                                "FieldWells": {
                                    "PieChartAggregatedFieldWells": {
                                        "Category": [
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${CLUSTERS_SUMMARY_DATASET}-alias.Region.1.1717557867849",
                                                    "Column": {
                                                        "DataSetIdentifier": "${CLUSTERS_SUMMARY_DATASET}",
                                                        "ColumnName": "Region"
                                                    },
                                                    "HierarchyId": "d4cd2c1e-4fdc-47e3-93cf-7a1c1966a653"
                                                }
                                            }
                                        ],
                                        "Values": [
                                            {
                                                "NumericalMeasureField": {
                                                    "FieldId": "${CLUSTERS_SUMMARY_DATASET}-alias.Number of Clusters.1.1717557769601",
                                                    "Column": {
                                                        "DataSetIdentifier": "${CLUSTERS_SUMMARY_DATASET}",
                                                        "ColumnName": "Number of Clusters"
                                                    },
                                                    "AggregationFunction": {
                                                        "SimpleNumericalAggregation": "SUM"
                                                    }
                                                }
                                            }
                                        ]
                                    }
                                },
                                "SortConfiguration": {
                                    "CategorySort": [
                                        {
                                            "FieldSort": {
                                                "FieldId": "${CLUSTERS_SUMMARY_DATASET}-alias.Number of Clusters.1.1717557769601",
                                                "Direction": "DESC"
                                            }
                                        }
                                    ],
                                    "CategoryItemsLimit": {
                                        "OtherCategories": "INCLUDE"
                                    },
                                    "SmallMultiplesLimitConfiguration": {
                                        "OtherCategories": "INCLUDE"
                                    }
                                },
                                "DonutOptions": {
                                    "ArcOptions": {
                                        "ArcThickness": "MEDIUM"
                                    }
                                },
                                "ValueLabelOptions": {
                                    "AxisLabelOptions": [
                                        {
                                            "CustomLabel": "Number of EKS Clusters per Region",
                                            "ApplyTo": {
                                                "FieldId": "${CLUSTERS_SUMMARY_DATASET}-alias.Number of Clusters.1.1717557769601",
                                                "Column": {
                                                    "DataSetIdentifier": "${CLUSTERS_SUMMARY_DATASET}",
                                                    "ColumnName": "Number of Clusters"
                                                }
                                            }
                                        }
                                    ]
                                },
                                "Legend": {
                                    "Width": "153px"
                                },
                                "DataLabels": {
                                    "Visibility": "VISIBLE",
                                    "Overlap": "DISABLE_OVERLAP"
                                },
                                "Tooltip": {
                                    "TooltipVisibility": "VISIBLE",
                                    "SelectedTooltipType": "DETAILED",
                                    "FieldBasedTooltip": {
                                        "AggregationVisibility": "HIDDEN",
                                        "TooltipTitleType": "PRIMARY_VALUE",
                                        "TooltipFields": [
                                            {
                                                "FieldTooltipItem": {
                                                    "FieldId": "${CLUSTERS_SUMMARY_DATASET}-alias.Number of Clusters.1.1717557769601",
                                                    "Visibility": "VISIBLE"
                                                }
                                            },
                                            {
                                                "FieldTooltipItem": {
                                                    "FieldId": "${CLUSTERS_SUMMARY_DATASET}-alias.Region.1.1717557867849",
                                                    "Visibility": "VISIBLE"
                                                }
                                            }
                                        ]
                                    }
                                }
                            },
                            "Actions": [],
                            "ColumnHierarchies": [
                                {
                                    "ExplicitHierarchy": {
                                        "HierarchyId": "d4cd2c1e-4fdc-47e3-93cf-7a1c1966a653",
                                        "Columns": [
                                            {
                                                "DataSetIdentifier": "${CLUSTERS_SUMMARY_DATASET}",
                                                "ColumnName": "Region"
                                            },
                                            {
                                                "DataSetIdentifier": "${CLUSTERS_SUMMARY_DATASET}",
                                                "ColumnName": "Account Id"
                                            }
                                        ],
                                        "DrillDownFilters": []
                                    }
                                }
                            ]
                        }
                    },
                    {
                        "BarChartVisual": {
                            "VisualId": "bdb12279-a3ba-4ebc-b177-56d797ad7f3d_e092d0c9-1d30-4357-a2e6-48e0592672fd",
                            "Title": {
                                "Visibility": "VISIBLE",
                                "FormatText": {
                                    "RichText": "<visual-title>\n  <b>EKS Versions per Account</b>\n</visual-title>"
                                }
                            },
                            "Subtitle": {
                                "Visibility": "VISIBLE"
                            },
                            "ChartConfiguration": {
                                "FieldWells": {
                                    "BarChartAggregatedFieldWells": {
                                        "Category": [
                                            {
                                                "NumericalDimensionField": {
                                                    "FieldId": "${CLUSTERS_DATA_DATASET}-alias.Cluster Version.0.1717557962338",
                                                    "Column": {
                                                        "DataSetIdentifier": "${CLUSTERS_DATA_DATASET}",
                                                        "ColumnName": "Cluster Version"
                                                    },
                                                    "FormatConfiguration": {
                                                        "FormatConfiguration": {
                                                            "NumberDisplayFormatConfiguration": {
                                                                "DecimalPlacesConfiguration": {
                                                                    "DecimalPlaces": 2
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        ],
                                        "Values": [],
                                        "Colors": [
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${CLUSTERS_DATA_DATASET}-alias.Account Id.1.1717557969574",
                                                    "Column": {
                                                        "DataSetIdentifier": "${CLUSTERS_DATA_DATASET}",
                                                        "ColumnName": "Account Id"
                                                    }
                                                }
                                            }
                                        ]
                                    }
                                },
                                "SortConfiguration": {
                                    "CategorySort": [
                                        {
                                            "FieldSort": {
                                                "FieldId": "${CLUSTERS_DATA_DATASET}-alias.Cluster Version.0.1717557962338",
                                                "Direction": "ASC"
                                            }
                                        }
                                    ],
                                    "CategoryItemsLimit": {
                                        "OtherCategories": "INCLUDE"
                                    },
                                    "ColorItemsLimit": {
                                        "OtherCategories": "INCLUDE"
                                    },
                                    "SmallMultiplesLimitConfiguration": {
                                        "OtherCategories": "INCLUDE"
                                    }
                                },
                                "Orientation": "VERTICAL",
                                "BarsArrangement": "STACKED",
                                "Legend": {
                                    "Width": "131px"
                                },
                                "DataLabels": {
                                    "Visibility": "HIDDEN",
                                    "Overlap": "DISABLE_OVERLAP"
                                },
                                "Tooltip": {
                                    "TooltipVisibility": "VISIBLE",
                                    "SelectedTooltipType": "DETAILED",
                                    "FieldBasedTooltip": {
                                        "AggregationVisibility": "HIDDEN",
                                        "TooltipTitleType": "PRIMARY_VALUE",
                                        "TooltipFields": [
                                            {
                                                "FieldTooltipItem": {
                                                    "FieldId": "${CLUSTERS_DATA_DATASET}-alias.Cluster Version.0.1717557962338",
                                                    "Visibility": "VISIBLE"
                                                }
                                            },
                                            {
                                                "FieldTooltipItem": {
                                                    "FieldId": "${CLUSTERS_DATA_DATASET}-alias.Account Id.1.1717557969574",
                                                    "Visibility": "VISIBLE"
                                                }
                                            }
                                        ]
                                    }
                                }
                            },
                            "Actions": [],
                            "ColumnHierarchies": []
                        }
                    },
                    {
                        "TableVisual": {
                            "VisualId": "bdb12279-a3ba-4ebc-b177-56d797ad7f3d_265e661c-fa82-4703-952f-055c5e826223",
                            "Title": {
                                "Visibility": "VISIBLE",
                                "FormatText": {
                                    "RichText": "<visual-title>\n  <b>Amazon EKS Kubernetes Release Calendar</b>\n</visual-title>"
                                }
                            },
                            "Subtitle": {
                                "Visibility": "VISIBLE"
                            },
                            "ChartConfiguration": {
                                "FieldWells": {
                                    "TableAggregatedFieldWells": {
                                        "GroupBy": [
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${KUBERNETES_RELEASE_CALENDAR}-alias.Kubernetes version.0.1717558041328",
                                                    "Column": {
                                                        "DataSetIdentifier": "${KUBERNETES_RELEASE_CALENDAR}",
                                                        "ColumnName": "Kubernetes Version"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${KUBERNETES_RELEASE_CALENDAR}-alias.Upstream release.5.1717558718789",
                                                    "Column": {
                                                        "DataSetIdentifier": "${KUBERNETES_RELEASE_CALENDAR}",
                                                        "ColumnName": "Upstream release"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${KUBERNETES_RELEASE_CALENDAR}-alias.Amazon EKS release.4.1717558728894",
                                                    "Column": {
                                                        "DataSetIdentifier": "${KUBERNETES_RELEASE_CALENDAR}",
                                                        "ColumnName": "Amazon EKS release"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${KUBERNETES_RELEASE_CALENDAR}-alias.End of standard support.4.1717558735703",
                                                    "Column": {
                                                        "DataSetIdentifier": "${KUBERNETES_RELEASE_CALENDAR}",
                                                        "ColumnName": "End of standard support"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${KUBERNETES_RELEASE_CALENDAR}-alias.End of extended support.4.1717558750432",
                                                    "Column": {
                                                        "DataSetIdentifier": "${KUBERNETES_RELEASE_CALENDAR}",
                                                        "ColumnName": "End of extended support"
                                                    }
                                                }
                                            }
                                        ],
                                        "Values": []
                                    }
                                },
                                "SortConfiguration": {
                                    "RowSort": [
                                        {
                                            "FieldSort": {
                                                "FieldId": "${KUBERNETES_RELEASE_CALENDAR}-alias.Kubernetes version.0.1717558041328",
                                                "Direction": "ASC"
                                            }
                                        }
                                    ]
                                },
                                "TableOptions": {
                                    "HeaderStyle": {
                                        "TextWrap": "WRAP",
                                        "Height": 25
                                    }
                                },
                                "FieldOptions": {
                                    "SelectedFieldOptions": [
                                        {
                                            "FieldId": "${KUBERNETES_RELEASE_CALENDAR}-alias.Kubernetes version.0.1717558041328",
                                            "Width": "147px"
                                        },
                                        {
                                            "FieldId": "${KUBERNETES_RELEASE_CALENDAR}-alias.Upstream release.5.1717558718789",
                                            "Width": "137px"
                                        }
                                    ],
                                    "Order": []
                                }
                            },
                            "Actions": []
                        }
                    },
                    {
                        "TableVisual": {
                            "VisualId": "bdb12279-a3ba-4ebc-b177-56d797ad7f3d_ec7bd7fd-aaea-45bc-8620-8f9b8a787c00",
                            "Title": {
                                "Visibility": "VISIBLE",
                                "FormatText": {
                                    "RichText": "<visual-title>\n  <b>EKS Clusters Support Availability</b>\n</visual-title>"
                                }
                            },
                            "Subtitle": {
                                "Visibility": "VISIBLE"
                            },
                            "ChartConfiguration": {
                                "FieldWells": {
                                    "TableAggregatedFieldWells": {
                                        "GroupBy": [
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${SUPPORT_DATA_DATASET}-alias.Account Id.0.1717558230386",
                                                    "Column": {
                                                        "DataSetIdentifier": "${SUPPORT_DATA_DATASET}",
                                                        "ColumnName": "Account Id"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${SUPPORT_DATA_DATASET}-alias.Region.1.1717558232404",
                                                    "Column": {
                                                        "DataSetIdentifier": "${SUPPORT_DATA_DATASET}",
                                                        "ColumnName": "Region"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${SUPPORT_DATA_DATASET}-alias.Cluster Name.2.1717558234123",
                                                    "Column": {
                                                        "DataSetIdentifier": "${SUPPORT_DATA_DATASET}",
                                                        "ColumnName": "Cluster Name"
                                                    }
                                                }
                                            },
                                            {
                                                "NumericalDimensionField": {
                                                    "FieldId": "${SUPPORT_DATA_DATASET}-alias.Cluster Version.3.1717558240622",
                                                    "Column": {
                                                        "DataSetIdentifier": "${SUPPORT_DATA_DATASET}",
                                                        "ColumnName": "Cluster Version"
                                                    },
                                                    "FormatConfiguration": {
                                                        "FormatConfiguration": {
                                                            "NumberDisplayFormatConfiguration": {
                                                                "DecimalPlacesConfiguration": {
                                                                    "DecimalPlaces": 2
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${SUPPORT_DATA_DATASET}-alias.Status.4.1717558252237",
                                                    "Column": {
                                                        "DataSetIdentifier": "${SUPPORT_DATA_DATASET}",
                                                        "ColumnName": "Support Status"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${SUPPORT_DATA_DATASET}-alias.EndOfSupportDate.5.1717558259159",
                                                    "Column": {
                                                        "DataSetIdentifier": "${SUPPORT_DATA_DATASET}",
                                                        "ColumnName": "End Of Standard Support Date"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${SUPPORT_DATA_DATASET}-alias.EndOfExtendedSupportDate.6.1717558260047",
                                                    "Column": {
                                                        "DataSetIdentifier": "${SUPPORT_DATA_DATASET}",
                                                        "ColumnName": "End Of Extended Support Date"
                                                    }
                                                }
                                            }
                                        ],
                                        "Values": []
                                    }
                                },
                                "SortConfiguration": {
                                    "RowSort": [
                                        {
                                            "FieldSort": {
                                                "FieldId": "${SUPPORT_DATA_DATASET}-alias.Cluster Version.3.1717558240622",
                                                "Direction": "ASC"
                                            }
                                        }
                                    ]
                                },
                                "TableOptions": {
                                    "HeaderStyle": {
                                        "TextWrap": "WRAP",
                                        "Height": 25
                                    }
                                },
                                "FieldOptions": {
                                    "SelectedFieldOptions": [
                                        {
                                            "FieldId": "${SUPPORT_DATA_DATASET}-alias.Account Id.0.1717558230386",
                                            "Width": "187px"
                                        },
                                        {
                                            "FieldId": "${SUPPORT_DATA_DATASET}-alias.Region.1.1717558232404",
                                            "Width": "164px"
                                        },
                                        {
                                            "FieldId": "${SUPPORT_DATA_DATASET}-alias.Cluster Name.2.1717558234123",
                                            "Width": "312px"
                                        },
                                        {
                                            "FieldId": "${SUPPORT_DATA_DATASET}-alias.Cluster Version.3.1717558240622",
                                            "Width": "155px"
                                        },
                                        {
                                            "FieldId": "${SUPPORT_DATA_DATASET}-alias.Status.4.1717558252237",
                                            "Width": "213px"
                                        },
                                        {
                                            "FieldId": "${SUPPORT_DATA_DATASET}-alias.EndOfSupportDate.5.1717558259159",
                                            "Width": "262px"
                                        },
                                        {
                                            "FieldId": "${SUPPORT_DATA_DATASET}-alias.EndOfExtendedSupportDate.6.1717558260047",
                                            "Width": "270px"
                                        }
                                    ],
                                    "Order": []
                                }
                            },
                            "Actions": []
                        }
                    },
                    {
                        "TableVisual": {
                            "VisualId": "bdb12279-a3ba-4ebc-b177-56d797ad7f3d_f1c5d2af-5ffa-4ceb-a3e7-b91a5405704e",
                            "Title": {
                                "Visibility": "VISIBLE",
                                "FormatText": {
                                    "RichText": "<visual-title>\n  <b>EKS Clusters Metadata</b>\n</visual-title>"
                                }
                            },
                            "Subtitle": {
                                "Visibility": "VISIBLE"
                            },
                            "ChartConfiguration": {
                                "FieldWells": {
                                    "TableAggregatedFieldWells": {
                                        "GroupBy": [
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${CLUSTERS_DETAILS_DATASET}-alias.Account Id.0.1717558354487",
                                                    "Column": {
                                                        "DataSetIdentifier": "${CLUSTERS_DETAILS_DATASET}",
                                                        "ColumnName": "Account Id"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${CLUSTERS_DETAILS_DATASET}-alias.Region.1.1717558358844",
                                                    "Column": {
                                                        "DataSetIdentifier": "${CLUSTERS_DETAILS_DATASET}",
                                                        "ColumnName": "Region"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${CLUSTERS_DETAILS_DATASET}-alias.Cluster Name.2.1717558360426",
                                                    "Column": {
                                                        "DataSetIdentifier": "${CLUSTERS_DETAILS_DATASET}",
                                                        "ColumnName": "Cluster Name"
                                                    }
                                                }
                                            },
                                            {
                                                "NumericalDimensionField": {
                                                    "FieldId": "${CLUSTERS_DETAILS_DATASET}-alias.Cluster Version.3.1717558365107",
                                                    "Column": {
                                                        "DataSetIdentifier": "${CLUSTERS_DETAILS_DATASET}",
                                                        "ColumnName": "Cluster Version"
                                                    },
                                                    "FormatConfiguration": {
                                                        "FormatConfiguration": {
                                                            "NumberDisplayFormatConfiguration": {
                                                                "DecimalPlacesConfiguration": {
                                                                    "DecimalPlaces": 2
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${CLUSTERS_DETAILS_DATASET}-alias.coredns.4.1717558379444",
                                                    "Column": {
                                                        "DataSetIdentifier": "${CLUSTERS_DETAILS_DATASET}",
                                                        "ColumnName": "Core DNS"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${CLUSTERS_DETAILS_DATASET}-alias.kube-proxy.5.1717558385898",
                                                    "Column": {
                                                        "DataSetIdentifier": "${CLUSTERS_DETAILS_DATASET}",
                                                        "ColumnName": "Kube Proxy"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${CLUSTERS_DETAILS_DATASET}-alias.vpc-cni.6.1717558386797",
                                                    "Column": {
                                                        "DataSetIdentifier": "${CLUSTERS_DETAILS_DATASET}",
                                                        "ColumnName": "VPC CNI"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${CLUSTERS_DETAILS_DATASET}-alias.aws-ebs-csi-driver.7.1717558387732",
                                                    "Column": {
                                                        "DataSetIdentifier": "${CLUSTERS_DETAILS_DATASET}",
                                                        "ColumnName": "EBS CSI Driver"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${CLUSTERS_DETAILS_DATASET}-alias.aws-efs-csi-driver.8.1717558388683",
                                                    "Column": {
                                                        "DataSetIdentifier": "${CLUSTERS_DETAILS_DATASET}",
                                                        "ColumnName": "EFS CSI Driver"
                                                    }
                                                }
                                            }
                                        ],
                                        "Values": []
                                    }
                                },
                                "SortConfiguration": {
                                    "RowSort": [
                                        {
                                            "FieldSort": {
                                                "FieldId": "${CLUSTERS_DETAILS_DATASET}-alias.Account Id.0.1717558354487",
                                                "Direction": "ASC"
                                            }
                                        }
                                    ]
                                },
                                "TableOptions": {
                                    "HeaderStyle": {
                                        "TextWrap": "WRAP",
                                        "Height": 25
                                    }
                                },
                                "FieldOptions": {
                                    "SelectedFieldOptions": [
                                        {
                                            "FieldId": "${CLUSTERS_DETAILS_DATASET}-alias.Account Id.0.1717558354487",
                                            "Width": "150px"
                                        },
                                        {
                                            "FieldId": "${CLUSTERS_DETAILS_DATASET}-alias.Region.1.1717558358844",
                                            "Width": "125px"
                                        },
                                        {
                                            "FieldId": "${CLUSTERS_DETAILS_DATASET}-alias.Cluster Name.2.1717558360426",
                                            "Width": "265px"
                                        },
                                        {
                                            "FieldId": "${CLUSTERS_DETAILS_DATASET}-alias.Cluster Version.3.1717558365107",
                                            "Width": "114px"
                                        },
                                        {
                                            "FieldId": "${CLUSTERS_DETAILS_DATASET}-alias.coredns.4.1717558379444",
                                            "Width": "174px"
                                        },
                                        {
                                            "FieldId": "${CLUSTERS_DETAILS_DATASET}-alias.kube-proxy.5.1717558385898",
                                            "Width": "188px"
                                        },
                                        {
                                            "FieldId": "${CLUSTERS_DETAILS_DATASET}-alias.vpc-cni.6.1717558386797",
                                            "Width": "189px"
                                        },
                                        {
                                            "FieldId": "${CLUSTERS_DETAILS_DATASET}-alias.aws-ebs-csi-driver.7.1717558387732",
                                            "Width": "182px"
                                        },
                                        {
                                            "FieldId": "${CLUSTERS_DETAILS_DATASET}-alias.aws-efs-csi-driver.8.1717558388683",
                                            "Width": "170px"
                                        }
                                    ],
                                    "Order": []
                                }
                            },
                            "Actions": []
                        }
                    },
                    {
                        "TableVisual": {
                            "VisualId": "bdb12279-a3ba-4ebc-b177-56d797ad7f3d_2447f2ad-daae-4afc-aef2-3d1e9d9585c8",
                            "Title": {
                                "Visibility": "VISIBLE",
                                "FormatText": {
                                    "RichText": "<visual-title>\n  <b>EKS Clusters Upgrade Insights</b>\n</visual-title>"
                                }
                            },
                            "Subtitle": {
                                "Visibility": "VISIBLE"
                            },
                            "ChartConfiguration": {
                                "FieldWells": {
                                    "TableAggregatedFieldWells": {
                                        "GroupBy": [
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${UPGRADE_INSIGHTS_DATASET}-alias.Account Id.0.1717558456622",
                                                    "Column": {
                                                        "DataSetIdentifier": "${UPGRADE_INSIGHTS_DATASET}",
                                                        "ColumnName": "Account Id"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${UPGRADE_INSIGHTS_DATASET}-alias.Region.1.1717558458894",
                                                    "Column": {
                                                        "DataSetIdentifier": "${UPGRADE_INSIGHTS_DATASET}",
                                                        "ColumnName": "Region"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${UPGRADE_INSIGHTS_DATASET}-alias.Cluster Name.2.1717558460057",
                                                    "Column": {
                                                        "DataSetIdentifier": "${UPGRADE_INSIGHTS_DATASET}",
                                                        "ColumnName": "Cluster Name"
                                                    }
                                                }
                                            },
                                            {
                                                "NumericalDimensionField": {
                                                    "FieldId": "${UPGRADE_INSIGHTS_DATASET}-alias.Cluster Version.3.1717558460978",
                                                    "Column": {
                                                        "DataSetIdentifier": "${UPGRADE_INSIGHTS_DATASET}",
                                                        "ColumnName": "Cluster Version"
                                                    },
                                                    "FormatConfiguration": {
                                                        "FormatConfiguration": {
                                                            "NumberDisplayFormatConfiguration": {
                                                                "DecimalPlacesConfiguration": {
                                                                    "DecimalPlaces": 2
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${UPGRADE_INSIGHTS_DATASET}-alias.Current API Usage.4.1717558473153",
                                                    "Column": {
                                                        "DataSetIdentifier": "${UPGRADE_INSIGHTS_DATASET}",
                                                        "ColumnName": "Current API Usage"
                                                    }
                                                }
                                            },
                                            {
                                                "NumericalDimensionField": {
                                                    "FieldId": "${UPGRADE_INSIGHTS_DATASET}-alias.API Deprecated Version.5.1717558474902",
                                                    "Column": {
                                                        "DataSetIdentifier": "${UPGRADE_INSIGHTS_DATASET}",
                                                        "ColumnName": "API Deprecated Version"
                                                    },
                                                    "FormatConfiguration": {
                                                        "FormatConfiguration": {
                                                            "NumberDisplayFormatConfiguration": {
                                                                "DecimalPlacesConfiguration": {
                                                                    "DecimalPlaces": 2
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${UPGRADE_INSIGHTS_DATASET}-alias.API Replacement.6.1717558480408",
                                                    "Column": {
                                                        "DataSetIdentifier": "${UPGRADE_INSIGHTS_DATASET}",
                                                        "ColumnName": "API Replacement"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${UPGRADE_INSIGHTS_DATASET}-alias.User Agent.7.1717558482035",
                                                    "Column": {
                                                        "DataSetIdentifier": "${UPGRADE_INSIGHTS_DATASET}",
                                                        "ColumnName": "User Agent"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "${UPGRADE_INSIGHTS_DATASET}-alias.Last Request Time.8.1717558497972",
                                                    "Column": {
                                                        "DataSetIdentifier": "${UPGRADE_INSIGHTS_DATASET}",
                                                        "ColumnName": "Last Request Time"
                                                    }
                                                }
                                            }
                                        ],
                                        "Values": [
                                            {
                                                "NumericalMeasureField": {
                                                    "FieldId": "${UPGRADE_INSIGHTS_DATASET}-alias.Number of Requests In Last 30Days.9.1717558502852",
                                                    "Column": {
                                                        "DataSetIdentifier": "${UPGRADE_INSIGHTS_DATASET}",
                                                        "ColumnName": "Number of Requests In Last 30Days"
                                                    },
                                                    "AggregationFunction": {
                                                        "SimpleNumericalAggregation": "SUM"
                                                    }
                                                }
                                            }
                                        ]
                                    }
                                },
                                "SortConfiguration": {
                                    "RowSort": [
                                        {
                                            "FieldSort": {
                                                "FieldId": "${UPGRADE_INSIGHTS_DATASET}-alias.Cluster Name.2.1717558460057",
                                                "Direction": "ASC"
                                            }
                                        }
                                    ]
                                },
                                "TableOptions": {
                                    "HeaderStyle": {
                                        "TextWrap": "WRAP",
                                        "Height": 25
                                    }
                                },
                                "FieldOptions": {
                                    "SelectedFieldOptions": [
                                        {
                                            "FieldId": "${UPGRADE_INSIGHTS_DATASET}-alias.Current API Usage.4.1717558473153",
                                            "Width": "390px"
                                        },
                                        {
                                            "FieldId": "${UPGRADE_INSIGHTS_DATASET}-alias.API Replacement.6.1717558480408",
                                            "Width": "384px"
                                        }
                                    ],
                                    "Order": [],
                                    "PinnedFieldOptions": {
                                        "PinnedLeftFields": [
                                            "${UPGRADE_INSIGHTS_DATASET}-alias.Account Id.0.1717558456622",
                                            "${UPGRADE_INSIGHTS_DATASET}-alias.Region.1.1717558458894",
                                            "${UPGRADE_INSIGHTS_DATASET}-alias.Cluster Name.2.1717558460057",
                                            "${UPGRADE_INSIGHTS_DATASET}-alias.Cluster Version.3.1717558460978"
                                        ]
                                    }
                                }
                            },
                            "Actions": []
                        }
                    }
                ],
                "Layouts": [
                    {
                        "Configuration": {
                            "GridLayout": {
                                "Elements": [
                                    {
                                        "ElementId": "bdb12279-a3ba-4ebc-b177-56d797ad7f3d_c07b4be0-f5ac-43e4-b3a2-a2ee57550175",
                                        "ElementType": "VISUAL",
                                        "ColumnIndex": 0,
                                        "ColumnSpan": 18,
                                        "RowIndex": 0,
                                        "RowSpan": 12
                                    },
                                    {
                                        "ElementId": "bdb12279-a3ba-4ebc-b177-56d797ad7f3d_476a235f-cbcf-40b4-8a16-d7fb30b8340b",
                                        "ElementType": "VISUAL",
                                        "ColumnIndex": 18,
                                        "ColumnSpan": 18,
                                        "RowIndex": 0,
                                        "RowSpan": 12
                                    },
                                    {
                                        "ElementId": "bdb12279-a3ba-4ebc-b177-56d797ad7f3d_e092d0c9-1d30-4357-a2e6-48e0592672fd",
                                        "ElementType": "VISUAL",
                                        "ColumnIndex": 0,
                                        "ColumnSpan": 18,
                                        "RowIndex": 12,
                                        "RowSpan": 12
                                    },
                                    {
                                        "ElementId": "bdb12279-a3ba-4ebc-b177-56d797ad7f3d_265e661c-fa82-4703-952f-055c5e826223",
                                        "ElementType": "VISUAL",
                                        "ColumnIndex": 18,
                                        "ColumnSpan": 18,
                                        "RowIndex": 12,
                                        "RowSpan": 12
                                    },
                                    {
                                        "ElementId": "bdb12279-a3ba-4ebc-b177-56d797ad7f3d_ec7bd7fd-aaea-45bc-8620-8f9b8a787c00",
                                        "ElementType": "VISUAL",
                                        "ColumnIndex": 0,
                                        "ColumnSpan": 36,
                                        "RowIndex": 24,
                                        "RowSpan": 7
                                    },
                                    {
                                        "ElementId": "bdb12279-a3ba-4ebc-b177-56d797ad7f3d_f1c5d2af-5ffa-4ceb-a3e7-b91a5405704e",
                                        "ElementType": "VISUAL",
                                        "ColumnIndex": 0,
                                        "ColumnSpan": 36,
                                        "RowIndex": 31,
                                        "RowSpan": 7
                                    },
                                    {
                                        "ElementId": "bdb12279-a3ba-4ebc-b177-56d797ad7f3d_2447f2ad-daae-4afc-aef2-3d1e9d9585c8",
                                        "ElementType": "VISUAL",
                                        "ColumnIndex": 0,
                                        "ColumnSpan": 36,
                                        "RowIndex": 38,
                                        "RowSpan": 12
                                    }
                                ],
                                "CanvasSizeOptions": {
                                    "ScreenCanvasSizeOptions": {
                                        "ResizeOption": "FIXED",
                                        "OptimizedViewPortWidth": "1600px"
                                    }
                                }
                            }
                        }
                    }
                ],
                "SheetControlLayouts": [
                    {
                        "Configuration": {
                            "GridLayout": {
                                "Elements": [
                                    {
                                        "ElementId": "037173c3-f0cb-441f-93f5-57bbd154a4aa",
                                        "ElementType": "FILTER_CONTROL",
                                        "ColumnSpan": 2,
                                        "RowSpan": 1
                                    },
                                    {
                                        "ElementId": "806c3717-09e9-4c08-bc3f-e664b0efb48d",
                                        "ElementType": "FILTER_CONTROL",
                                        "ColumnSpan": 2,
                                        "RowSpan": 1
                                    },
                                    {
                                        "ElementId": "eedbf19d-8c30-424f-8479-4581d6ce96ff",
                                        "ElementType": "FILTER_CONTROL",
                                        "ColumnSpan": 2,
                                        "RowSpan": 1
                                    },
                                    {
                                        "ElementId": "9f63b22c-6d75-4559-87aa-3ad875b643dd",
                                        "ElementType": "FILTER_CONTROL",
                                        "ColumnSpan": 2,
                                        "RowSpan": 1
                                    },
                                    {
                                        "ElementId": "3ee97d72-e777-4b41-87af-fe3418f46c57",
                                        "ElementType": "FILTER_CONTROL",
                                        "ColumnSpan": 2,
                                        "RowSpan": 1
                                    }
                                ]
                            }
                        }
                    }
                ],
                "ContentType": "INTERACTIVE"
            },
            {
                "SheetId": "dbf1b80a-b1a3-4823-9bdc-7688fa9006ba_caa5ffbc-4e80-4c4e-9dec-ce1f358c21a0",
                "Name": "Argo Projects",
                "FilterControls": [
                    {
                        "Dropdown": {
                            "FilterControlId": "d4d1331b-9d79-42e7-87c0-0660109c3f3c",
                            "Title": "Account Id",
                            "SourceFilterId": "c9581083-c34f-4ede-bca9-7b14bf41f335",
                            "DisplayOptions": {
                                "SelectAllOptions": {
                                    "Visibility": "VISIBLE"
                                },
                                "TitleOptions": {
                                    "Visibility": "VISIBLE",
                                    "FontConfiguration": {
                                        "FontSize": {
                                            "Relative": "MEDIUM"
                                        }
                                    }
                                },
                                "InfoIconLabelOptions": {
                                    "Visibility": "HIDDEN"
                                }
                            },
                            "Type": "MULTI_SELECT"
                        }
                    },
                    {
                        "Dropdown": {
                            "FilterControlId": "97268c73-a6a3-4dad-a34a-68452cefb558",
                            "Title": "Region",
                            "SourceFilterId": "27f289e6-5ebe-4e5e-8318-1509455ffe59",
                            "DisplayOptions": {
                                "SelectAllOptions": {
                                    "Visibility": "VISIBLE"
                                },
                                "TitleOptions": {
                                    "Visibility": "VISIBLE",
                                    "FontConfiguration": {
                                        "FontSize": {
                                            "Relative": "MEDIUM"
                                        }
                                    }
                                },
                                "InfoIconLabelOptions": {
                                    "Visibility": "HIDDEN"
                                }
                            },
                            "Type": "MULTI_SELECT"
                        }
                    },
                    {
                        "Dropdown": {
                            "FilterControlId": "ee6a26a9-4e6e-44e3-93a2-55e1cb9667ca",
                            "Title": "Cluster Name",
                            "SourceFilterId": "6022313a-ace3-4c56-909e-d982be1e2873",
                            "DisplayOptions": {
                                "SelectAllOptions": {
                                    "Visibility": "VISIBLE"
                                },
                                "TitleOptions": {
                                    "Visibility": "VISIBLE",
                                    "FontConfiguration": {
                                        "FontSize": {
                                            "Relative": "MEDIUM"
                                        }
                                    }
                                },
                                "InfoIconLabelOptions": {
                                    "Visibility": "HIDDEN"
                                }
                            },
                            "Type": "MULTI_SELECT"
                        }
                    },
                    {
                        "Dropdown": {
                            "FilterControlId": "60089ea0-e80f-4e9f-904b-583fab87322f",
                            "Title": "Application Name",
                            "SourceFilterId": "7c03d733-63de-48a7-b797-15d3afcb2244",
                            "DisplayOptions": {
                                "SelectAllOptions": {
                                    "Visibility": "VISIBLE"
                                },
                                "TitleOptions": {
                                    "Visibility": "VISIBLE",
                                    "FontConfiguration": {
                                        "FontSize": {
                                            "Relative": "MEDIUM"
                                        }
                                    }
                                },
                                "InfoIconLabelOptions": {
                                    "Visibility": "HIDDEN"
                                }
                            },
                            "Type": "MULTI_SELECT"
                        }
                    },
                    {
                        "Dropdown": {
                            "FilterControlId": "d0fd7a91-4848-4ff3-bf0d-9642a954ba6e",
                            "Title": "Application Health",
                            "SourceFilterId": "a937c571-57aa-4902-afd4-d8fb221eac1c",
                            "DisplayOptions": {
                                "SelectAllOptions": {
                                    "Visibility": "VISIBLE"
                                },
                                "TitleOptions": {
                                    "Visibility": "VISIBLE",
                                    "FontConfiguration": {
                                        "FontSize": {
                                            "Relative": "MEDIUM"
                                        }
                                    }
                                },
                                "InfoIconLabelOptions": {
                                    "Visibility": "HIDDEN"
                                }
                            },
                            "Type": "MULTI_SELECT"
                        }
                    },
                    {
                        "Dropdown": {
                            "FilterControlId": "7c03265f-c33d-42f6-b9ec-54fa29f51519",
                            "Title": "Application Sync",
                            "SourceFilterId": "b564dfa9-c40d-459e-9bb6-73d2b451c557",
                            "DisplayOptions": {
                                "SelectAllOptions": {
                                    "Visibility": "VISIBLE"
                                },
                                "TitleOptions": {
                                    "Visibility": "VISIBLE",
                                    "FontConfiguration": {
                                        "FontSize": {
                                            "Relative": "MEDIUM"
                                        }
                                    }
                                },
                                "InfoIconLabelOptions": {
                                    "Visibility": "HIDDEN"
                                }
                            },
                            "Type": "MULTI_SELECT"
                        }
                    }
                ],
                "Visuals": [
                    {
                        "TableVisual": {
                            "VisualId": "dbf1b80a-b1a3-4823-9bdc-7688fa9006ba_d7187c26-5898-4de5-8dd1-be33da926453",
                            "Title": {
                                "Visibility": "VISIBLE",
                                "FormatText": {
                                    "RichText": "<visual-title>\n  <b>Argo Projects Data</b>\n</visual-title>"
                                }
                            },
                            "Subtitle": {
                                "Visibility": "VISIBLE"
                            },
                            "ChartConfiguration": {
                                "FieldWells": {
                                    "TableAggregatedFieldWells": {
                                        "GroupBy": [
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Account Id.0.1724623897429",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Account Id"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Region.1.1724623909661",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Region"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Cluster Name.2.1724623910840",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Cluster Name"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Argo Application Name.3.1724623914864",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Argo Application Name"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Application Repo.4.1724623916729",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Application Repo"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Source Type.7.1724626003447",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Source Type"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Application Health.5.1724623920128",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Application Health"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Application Sync Status.6.1724623921331",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Application Sync Status"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Last Sync.8.1724626012188",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Last Sync"
                                                    }
                                                }
                                            }
                                        ],
                                        "Values": []
                                    }
                                },
                                "SortConfiguration": {
                                    "RowSort": [
                                        {
                                            "FieldSort": {
                                                "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Cluster Name.2.1724623910840",
                                                "Direction": "ASC"
                                            }
                                        }
                                    ]
                                },
                                "TableOptions": {
                                    "HeaderStyle": {
                                        "TextWrap": "WRAP",
                                        "Height": 25
                                    },
                                    "CellStyle": {
                                        "Height": 25
                                    }
                                },
                                "FieldOptions": {
                                    "SelectedFieldOptions": [
                                        {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Account Id.0.1724623897429",
                                            "Width": "116px"
                                        },
                                        {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Region.1.1724623909661",
                                            "Width": "97px"
                                        },
                                        {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Cluster Name.2.1724623910840",
                                            "Width": "161px"
                                        },
                                        {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Argo Application Name.3.1724623914864",
                                            "Width": "171px"
                                        },
                                        {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Application Repo.4.1724623916729",
                                            "Width": "352px"
                                        },
                                        {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Source Type.7.1724626003447",
                                            "Width": "97px"
                                        },
                                        {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Application Health.5.1724623920128",
                                            "Width": "126px"
                                        },
                                        {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Application Sync Status.6.1724623921331",
                                            "Width": "157px"
                                        }
                                    ],
                                    "Order": [],
                                    "PinnedFieldOptions": {
                                        "PinnedLeftFields": [
                                            "0b14bdd9-adc0-4382-be41-046e999e7090.Account Id.0.1724623897429",
                                            "0b14bdd9-adc0-4382-be41-046e999e7090.Region.1.1724623909661",
                                            "0b14bdd9-adc0-4382-be41-046e999e7090.Cluster Name.2.1724623910840"
                                        ]
                                    }
                                }
                            },
                            "ConditionalFormatting": {
                                "ConditionalFormattingOptions": [
                                    {
                                        "Cell": {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Application Health.5.1724623920128",
                                            "TextFormat": {
                                                "BackgroundColor": {
                                                    "Solid": {
                                                        "Expression": "locate({Application Health}, \"Missing\") > 0",
                                                        "Color": "#DE3B00"
                                                    }
                                                }
                                            }
                                        }
                                    },
                                    {
                                        "Cell": {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Application Health.5.1724623920128",
                                            "TextFormat": {
                                                "BackgroundColor": {
                                                    "Solid": {
                                                        "Expression": "locate({Application Health}, \"Healthy\") > 0",
                                                        "Color": "#B9E52F"
                                                    }
                                                }
                                            }
                                        }
                                    },
                                    {
                                        "Cell": {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Application Health.5.1724623920128",
                                            "TextFormat": {
                                                "BackgroundColor": {
                                                    "Solid": {
                                                        "Expression": "locate({Application Health}, \"Healthy, Missing\") = 0",
                                                        "Color": "#FF8700"
                                                    }
                                                }
                                            }
                                        }
                                    },
                                    {
                                        "Cell": {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Application Sync Status.6.1724623921331",
                                            "TextFormat": {
                                                "BackgroundColor": {
                                                    "Solid": {
                                                        "Expression": "locate({Application Sync Status}, \"Synced\") > 0",
                                                        "Color": "#B9E52F"
                                                    }
                                                }
                                            }
                                        }
                                    },
                                    {
                                        "Cell": {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Application Sync Status.6.1724623921331",
                                            "TextFormat": {
                                                "BackgroundColor": {
                                                    "Solid": {
                                                        "Expression": "locate({Application Sync Status}, \"OutOfSync\") > 0",
                                                        "Color": "#DE3B00"
                                                    }
                                                }
                                            }
                                        }
                                    }
                                ]
                            },
                            "Actions": []
                        }
                    },
                    {
                        "PieChartVisual": {
                            "VisualId": "dbf1b80a-b1a3-4823-9bdc-7688fa9006ba_60e5b9ee-ee61-4edf-be7c-dee8f548f570",
                            "Title": {
                                "Visibility": "VISIBLE",
                                "FormatText": {
                                    "RichText": "<visual-title>\n  <b>Number of GitOps Deployments and Health Status</b>\n</visual-title>"
                                }
                            },
                            "Subtitle": {
                                "Visibility": "VISIBLE"
                            },
                            "ChartConfiguration": {
                                "FieldWells": {
                                    "PieChartAggregatedFieldWells": {
                                        "Category": [
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Application Health.0.1724625055644",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Application Health"
                                                    }
                                                }
                                            }
                                        ],
                                        "Values": []
                                    }
                                },
                                "SortConfiguration": {
                                    "CategoryItemsLimit": {
                                        "OtherCategories": "INCLUDE"
                                    },
                                    "SmallMultiplesLimitConfiguration": {
                                        "OtherCategories": "INCLUDE"
                                    }
                                },
                                "DonutOptions": {
                                    "ArcOptions": {
                                        "ArcThickness": "MEDIUM"
                                    }
                                },
                                "Legend": {
                                    "Width": "136px"
                                },
                                "DataLabels": {
                                    "Visibility": "VISIBLE",
                                    "Overlap": "DISABLE_OVERLAP"
                                },
                                "Tooltip": {
                                    "TooltipVisibility": "VISIBLE",
                                    "SelectedTooltipType": "DETAILED",
                                    "FieldBasedTooltip": {
                                        "AggregationVisibility": "HIDDEN",
                                        "TooltipTitleType": "PRIMARY_VALUE",
                                        "TooltipFields": [
                                            {
                                                "FieldTooltipItem": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Application Health.0.1724625055644",
                                                    "Visibility": "VISIBLE"
                                                }
                                            }
                                        ]
                                    }
                                }
                            },
                            "Actions": [],
                            "ColumnHierarchies": []
                        }
                    },
                    {
                        "PieChartVisual": {
                            "VisualId": "dbf1b80a-b1a3-4823-9bdc-7688fa9006ba_a22a038b-c3bc-49ff-937f-838febc5ea64",
                            "Title": {
                                "Visibility": "VISIBLE",
                                "FormatText": {
                                    "RichText": "<visual-title>\n  <b>Number of GitOps Deployments and Sync Status</b>\n</visual-title>"
                                }
                            },
                            "Subtitle": {
                                "Visibility": "VISIBLE"
                            },
                            "ChartConfiguration": {
                                "FieldWells": {
                                    "PieChartAggregatedFieldWells": {
                                        "Category": [
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Application Sync Status.0.1724625213950",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Application Sync Status"
                                                    }
                                                }
                                            }
                                        ],
                                        "Values": []
                                    }
                                },
                                "SortConfiguration": {
                                    "CategoryItemsLimit": {
                                        "OtherCategories": "INCLUDE"
                                    },
                                    "SmallMultiplesLimitConfiguration": {
                                        "OtherCategories": "INCLUDE"
                                    }
                                },
                                "DonutOptions": {
                                    "ArcOptions": {
                                        "ArcThickness": "MEDIUM"
                                    }
                                },
                                "Legend": {
                                    "Width": "168px"
                                },
                                "DataLabels": {
                                    "Visibility": "VISIBLE",
                                    "Overlap": "DISABLE_OVERLAP"
                                },
                                "Tooltip": {
                                    "TooltipVisibility": "VISIBLE",
                                    "SelectedTooltipType": "DETAILED",
                                    "FieldBasedTooltip": {
                                        "AggregationVisibility": "HIDDEN",
                                        "TooltipTitleType": "PRIMARY_VALUE",
                                        "TooltipFields": [
                                            {
                                                "FieldTooltipItem": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Application Sync Status.0.1724625213950",
                                                    "Visibility": "VISIBLE"
                                                }
                                            }
                                        ]
                                    }
                                }
                            },
                            "Actions": [],
                            "ColumnHierarchies": []
                        }
                    },
                    {
                        "PieChartVisual": {
                            "VisualId": "dbf1b80a-b1a3-4823-9bdc-7688fa9006ba_ea1ac875-0bda-4ea4-9c9f-aa298775afdf",
                            "Title": {
                                "Visibility": "VISIBLE",
                                "FormatText": {
                                    "RichText": "<visual-title>\n  <b>Top 20 Argo Applications</b>\n</visual-title>"
                                }
                            },
                            "Subtitle": {
                                "Visibility": "VISIBLE"
                            },
                            "ChartConfiguration": {
                                "FieldWells": {
                                    "PieChartAggregatedFieldWells": {
                                        "Category": [
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Argo Application Name.0.1724625279719",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Argo Application Name"
                                                    }
                                                }
                                            }
                                        ],
                                        "Values": []
                                    }
                                },
                                "SortConfiguration": {
                                    "CategoryItemsLimit": {
                                        "OtherCategories": "INCLUDE"
                                    },
                                    "SmallMultiplesLimitConfiguration": {
                                        "OtherCategories": "INCLUDE"
                                    }
                                },
                                "DonutOptions": {
                                    "ArcOptions": {
                                        "ArcThickness": "WHOLE"
                                    }
                                },
                                "Legend": {
                                    "Width": "142px"
                                },
                                "DataLabels": {
                                    "Visibility": "VISIBLE",
                                    "Overlap": "DISABLE_OVERLAP"
                                },
                                "Tooltip": {
                                    "TooltipVisibility": "VISIBLE",
                                    "SelectedTooltipType": "DETAILED",
                                    "FieldBasedTooltip": {
                                        "AggregationVisibility": "HIDDEN",
                                        "TooltipTitleType": "PRIMARY_VALUE",
                                        "TooltipFields": [
                                            {
                                                "FieldTooltipItem": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Argo Application Name.0.1724625279719",
                                                    "Visibility": "VISIBLE"
                                                }
                                            }
                                        ]
                                    }
                                }
                            },
                            "Actions": [],
                            "ColumnHierarchies": []
                        }
                    },
                    {
                        "PieChartVisual": {
                            "VisualId": "dbf1b80a-b1a3-4823-9bdc-7688fa9006ba_eb2834cf-16e5-48a5-9085-4b9fa4e897d0",
                            "Title": {
                                "Visibility": "VISIBLE",
                                "FormatText": {
                                    "RichText": "<visual-title>\n  <b>Operation State Across Projects</b>\n</visual-title>"
                                }
                            },
                            "Subtitle": {
                                "Visibility": "VISIBLE"
                            },
                            "ChartConfiguration": {
                                "FieldWells": {
                                    "PieChartAggregatedFieldWells": {
                                        "Category": [
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Operation State.0.1724626177985",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Operation State"
                                                    }
                                                }
                                            }
                                        ],
                                        "Values": []
                                    }
                                },
                                "SortConfiguration": {
                                    "CategoryItemsLimit": {
                                        "OtherCategories": "INCLUDE"
                                    },
                                    "SmallMultiplesLimitConfiguration": {
                                        "OtherCategories": "INCLUDE"
                                    }
                                },
                                "DonutOptions": {
                                    "ArcOptions": {
                                        "ArcThickness": "WHOLE"
                                    }
                                },
                                "Legend": {
                                    "Width": "116px"
                                },
                                "DataLabels": {
                                    "Visibility": "VISIBLE",
                                    "Overlap": "DISABLE_OVERLAP"
                                },
                                "Tooltip": {
                                    "TooltipVisibility": "VISIBLE",
                                    "SelectedTooltipType": "DETAILED",
                                    "FieldBasedTooltip": {
                                        "AggregationVisibility": "HIDDEN",
                                        "TooltipTitleType": "PRIMARY_VALUE",
                                        "TooltipFields": [
                                            {
                                                "FieldTooltipItem": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Operation State.0.1724626177985",
                                                    "Visibility": "VISIBLE"
                                                }
                                            }
                                        ]
                                    }
                                }
                            },
                            "Actions": [],
                            "ColumnHierarchies": []
                        }
                    },
                    {
                        "TableVisual": {
                            "VisualId": "dbf1b80a-b1a3-4823-9bdc-7688fa9006ba_a8ce434c-90f3-4db7-8950-085564bd85aa",
                            "Title": {
                                "Visibility": "VISIBLE",
                                "FormatText": {
                                    "RichText": "<visual-title>\n  <b>Argo Resources Data</b>\n</visual-title>"
                                }
                            },
                            "Subtitle": {
                                "Visibility": "VISIBLE"
                            },
                            "ChartConfiguration": {
                                "FieldWells": {
                                    "TableAggregatedFieldWells": {
                                        "GroupBy": [
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Account Id.0.1724627045575",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Account Id"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Region.1.1724627047670",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Region"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Cluster Name.2.1724627061557",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Cluster Name"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Argo Application Name.9.1724684336460",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Argo Application Name"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Resource Name.3.1724627084881",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Resource Name"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Resource Kind.4.1724627086938",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Resource Kind"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Resource Namespace.5.1724627089501",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Resource Namespace"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Resource Health.6.1724627115136",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Resource Health"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Resource Status.7.1724627116887",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Resource Status"
                                                    }
                                                }
                                            },
                                            {
                                                "CategoricalDimensionField": {
                                                    "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Resource Version.8.1724627118022",
                                                    "Column": {
                                                        "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                                        "ColumnName": "Resource Version"
                                                    }
                                                }
                                            }
                                        ],
                                        "Values": []
                                    }
                                },
                                "SortConfiguration": {
                                    "RowSort": [
                                        {
                                            "FieldSort": {
                                                "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Cluster Name.2.1724627061557",
                                                "Direction": "ASC"
                                            }
                                        }
                                    ]
                                },
                                "TableOptions": {
                                    "HeaderStyle": {
                                        "TextWrap": "WRAP",
                                        "Height": 25
                                    },
                                    "CellStyle": {
                                        "Height": 25
                                    }
                                },
                                "FieldOptions": {
                                    "SelectedFieldOptions": [
                                        {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Account Id.0.1724627045575",
                                            "Width": "122px"
                                        },
                                        {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Region.1.1724627047670",
                                            "Width": "83px"
                                        },
                                        {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Cluster Name.2.1724627061557",
                                            "Width": "155px"
                                        },
                                        {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Resource Name.3.1724627084881",
                                            "Width": "259px"
                                        },
                                        {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Resource Kind.4.1724627086938",
                                            "Width": "129px"
                                        },
                                        {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Resource Namespace.5.1724627089501",
                                            "Width": "135px"
                                        },
                                        {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Resource Health.6.1724627115136",
                                            "Width": "120px"
                                        },
                                        {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Resource Status.7.1724627116887",
                                            "Width": "111px"
                                        },
                                        {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Resource Version.8.1724627118022",
                                            "Width": "116px"
                                        }
                                    ],
                                    "Order": []
                                }
                            },
                            "ConditionalFormatting": {
                                "ConditionalFormattingOptions": [
                                    {
                                        "Cell": {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Resource Status.7.1724627116887",
                                            "TextFormat": {
                                                "BackgroundColor": {
                                                    "Solid": {
                                                        "Expression": "locate({Resource Status}, \"Synced\") > 0",
                                                        "Color": "#B9E52F"
                                                    }
                                                }
                                            }
                                        }
                                    },
                                    {
                                        "Cell": {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Resource Status.7.1724627116887",
                                            "TextFormat": {
                                                "BackgroundColor": {
                                                    "Solid": {
                                                        "Expression": "locate({Resource Status}, \"OutOfSync\") > 0",
                                                        "Color": "#DE3B00"
                                                    }
                                                }
                                            }
                                        }
                                    },
                                    {
                                        "Cell": {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Resource Health.6.1724627115136",
                                            "TextFormat": {
                                                "BackgroundColor": {
                                                    "Solid": {
                                                        "Expression": "locate({Resource Health}, \"Missing\") > 0",
                                                        "Color": "#DE3B00"
                                                    }
                                                }
                                            }
                                        }
                                    },
                                    {
                                        "Cell": {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Resource Health.6.1724627115136",
                                            "TextFormat": {
                                                "BackgroundColor": {
                                                    "Solid": {
                                                        "Expression": "locate({Resource Health}, \"Healthy\") > 0",
                                                        "Color": "#B9E52F"
                                                    }
                                                }
                                            }
                                        }
                                    },
                                    {
                                        "Cell": {
                                            "FieldId": "0b14bdd9-adc0-4382-be41-046e999e7090.Resource Health.6.1724627115136",
                                            "TextFormat": {
                                                "BackgroundColor": {
                                                    "Solid": {
                                                        "Expression": "locate({Resource Health}, \"Missing, Healthy\") = 0",
                                                        "Color": "#FF8700"
                                                    }
                                                }
                                            }
                                        }
                                    }
                                ]
                            },
                            "Actions": []
                        }
                    }
                ],
                "Layouts": [
                    {
                        "Configuration": {
                            "GridLayout": {
                                "Elements": [
                                    {
                                        "ElementId": "dbf1b80a-b1a3-4823-9bdc-7688fa9006ba_d7187c26-5898-4de5-8dd1-be33da926453",
                                        "ElementType": "VISUAL",
                                        "ColumnIndex": 0,
                                        "ColumnSpan": 32,
                                        "RowIndex": 0,
                                        "RowSpan": 6
                                    },
                                    {
                                        "ElementId": "dbf1b80a-b1a3-4823-9bdc-7688fa9006ba_60e5b9ee-ee61-4edf-be7c-dee8f548f570",
                                        "ElementType": "VISUAL",
                                        "ColumnIndex": 0,
                                        "ColumnSpan": 16,
                                        "RowIndex": 6,
                                        "RowSpan": 12
                                    },
                                    {
                                        "ElementId": "dbf1b80a-b1a3-4823-9bdc-7688fa9006ba_a22a038b-c3bc-49ff-937f-838febc5ea64",
                                        "ElementType": "VISUAL",
                                        "ColumnIndex": 16,
                                        "ColumnSpan": 16,
                                        "RowIndex": 6,
                                        "RowSpan": 12
                                    },
                                    {
                                        "ElementId": "dbf1b80a-b1a3-4823-9bdc-7688fa9006ba_ea1ac875-0bda-4ea4-9c9f-aa298775afdf",
                                        "ElementType": "VISUAL",
                                        "ColumnIndex": 0,
                                        "ColumnSpan": 16,
                                        "RowIndex": 18,
                                        "RowSpan": 12
                                    },
                                    {
                                        "ElementId": "dbf1b80a-b1a3-4823-9bdc-7688fa9006ba_eb2834cf-16e5-48a5-9085-4b9fa4e897d0",
                                        "ElementType": "VISUAL",
                                        "ColumnIndex": 16,
                                        "ColumnSpan": 16,
                                        "RowIndex": 18,
                                        "RowSpan": 12
                                    },
                                    {
                                        "ElementId": "dbf1b80a-b1a3-4823-9bdc-7688fa9006ba_a8ce434c-90f3-4db7-8950-085564bd85aa",
                                        "ElementType": "VISUAL",
                                        "ColumnIndex": 0,
                                        "ColumnSpan": 32,
                                        "RowIndex": 30,
                                        "RowSpan": 12
                                    }
                                ],
                                "CanvasSizeOptions": {
                                    "ScreenCanvasSizeOptions": {
                                        "ResizeOption": "FIXED",
                                        "OptimizedViewPortWidth": "1600px"
                                    }
                                }
                            }
                        }
                    }
                ],
                "SheetControlLayouts": [
                    {
                        "Configuration": {
                            "GridLayout": {
                                "Elements": [
                                    {
                                        "ElementId": "d4d1331b-9d79-42e7-87c0-0660109c3f3c",
                                        "ElementType": "FILTER_CONTROL",
                                        "ColumnSpan": 2,
                                        "RowSpan": 1
                                    },
                                    {
                                        "ElementId": "97268c73-a6a3-4dad-a34a-68452cefb558",
                                        "ElementType": "FILTER_CONTROL",
                                        "ColumnSpan": 2,
                                        "RowSpan": 1
                                    },
                                    {
                                        "ElementId": "ee6a26a9-4e6e-44e3-93a2-55e1cb9667ca",
                                        "ElementType": "FILTER_CONTROL",
                                        "ColumnSpan": 2,
                                        "RowSpan": 1
                                    },
                                    {
                                        "ElementId": "60089ea0-e80f-4e9f-904b-583fab87322f",
                                        "ElementType": "FILTER_CONTROL",
                                        "ColumnSpan": 2,
                                        "RowSpan": 1
                                    },
                                    {
                                        "ElementId": "d0fd7a91-4848-4ff3-bf0d-9642a954ba6e",
                                        "ElementType": "FILTER_CONTROL",
                                        "ColumnSpan": 2,
                                        "RowSpan": 1
                                    },
                                    {
                                        "ElementId": "7c03265f-c33d-42f6-b9ec-54fa29f51519",
                                        "ElementType": "FILTER_CONTROL",
                                        "ColumnSpan": 2,
                                        "RowSpan": 1
                                    }
                                ]
                            }
                        }
                    }
                ],
                "ContentType": "INTERACTIVE"
            }
        ],
        "CalculatedFields": [],
        "ParameterDeclarations": [],
        "FilterGroups": [
            {
                "FilterGroupId": "08bb6416-670b-4930-b5e4-cad21f763205",
                "Filters": [
                    {
                        "CategoryFilter": {
                            "FilterId": "b2caec24-6838-4ff1-b6ab-6379fa41c1d9",
                            "Column": {
                                "DataSetIdentifier": "${CLUSTERS_DATA_DATASET}",
                                "ColumnName": "Account Id"
                            },
                            "Configuration": {
                                "FilterListConfiguration": {
                                    "MatchOperator": "CONTAINS",
                                    "SelectAllOptions": "FILTER_ALL_VALUES",
                                    "NullOption": "NON_NULLS_ONLY"
                                }
                            }
                        }
                    }
                ],
                "ScopeConfiguration": {
                    "SelectedSheets": {
                        "SheetVisualScopingConfigurations": [
                            {
                                "SheetId": "bdb12279-a3ba-4ebc-b177-56d797ad7f3d_bbd4e626-2b1f-40f6-a6c7-c2acf7f1f896",
                                "Scope": "ALL_VISUALS"
                            }
                        ]
                    }
                },
                "Status": "ENABLED",
                "CrossDataset": "ALL_DATASETS"
            },
            {
                "FilterGroupId": "3d51c83c-dd7c-4dd1-a933-937460598737",
                "Filters": [
                    {
                        "CategoryFilter": {
                            "FilterId": "c479d2a1-9f37-4ab3-855b-c902b9fab861",
                            "Column": {
                                "DataSetIdentifier": "${CLUSTERS_DATA_DATASET}",
                                "ColumnName": "Region"
                            },
                            "Configuration": {
                                "FilterListConfiguration": {
                                    "MatchOperator": "CONTAINS",
                                    "SelectAllOptions": "FILTER_ALL_VALUES",
                                    "NullOption": "NON_NULLS_ONLY"
                                }
                            }
                        }
                    }
                ],
                "ScopeConfiguration": {
                    "SelectedSheets": {
                        "SheetVisualScopingConfigurations": [
                            {
                                "SheetId": "bdb12279-a3ba-4ebc-b177-56d797ad7f3d_bbd4e626-2b1f-40f6-a6c7-c2acf7f1f896",
                                "Scope": "ALL_VISUALS"
                            }
                        ]
                    }
                },
                "Status": "ENABLED",
                "CrossDataset": "ALL_DATASETS"
            },
            {
                "FilterGroupId": "1d3f090f-c829-4338-90d7-44733dde470d",
                "Filters": [
                    {
                        "CategoryFilter": {
                            "FilterId": "eb2717c1-ea04-4039-9cdd-65935bb59e46",
                            "Column": {
                                "DataSetIdentifier": "${CLUSTERS_DATA_DATASET}",
                                "ColumnName": "Cluster Name"
                            },
                            "Configuration": {
                                "FilterListConfiguration": {
                                    "MatchOperator": "CONTAINS",
                                    "SelectAllOptions": "FILTER_ALL_VALUES",
                                    "NullOption": "NON_NULLS_ONLY"
                                }
                            }
                        }
                    }
                ],
                "ScopeConfiguration": {
                    "SelectedSheets": {
                        "SheetVisualScopingConfigurations": [
                            {
                                "SheetId": "bdb12279-a3ba-4ebc-b177-56d797ad7f3d_bbd4e626-2b1f-40f6-a6c7-c2acf7f1f896",
                                "Scope": "ALL_VISUALS"
                            }
                        ]
                    }
                },
                "Status": "ENABLED",
                "CrossDataset": "ALL_DATASETS"
            },
            {
                "FilterGroupId": "260cb185-cf44-4b8f-bf06-384df7185cef",
                "Filters": [
                    {
                        "NumericEqualityFilter": {
                            "FilterId": "e18f6a58-8cb1-4bfa-be98-fc721aa2db84",
                            "Column": {
                                "DataSetIdentifier": "${CLUSTERS_DATA_DATASET}",
                                "ColumnName": "Cluster Version"
                            },
                            "SelectAllOptions": "FILTER_ALL_VALUES",
                            "MatchOperator": "EQUALS",
                            "NullOption": "ALL_VALUES"
                        }
                    }
                ],
                "ScopeConfiguration": {
                    "SelectedSheets": {
                        "SheetVisualScopingConfigurations": [
                            {
                                "SheetId": "bdb12279-a3ba-4ebc-b177-56d797ad7f3d_bbd4e626-2b1f-40f6-a6c7-c2acf7f1f896",
                                "Scope": "ALL_VISUALS"
                            }
                        ]
                    }
                },
                "Status": "ENABLED",
                "CrossDataset": "ALL_DATASETS"
            },
            {
                "FilterGroupId": "b0868433-b230-49c8-8dc9-ea94fb6a0f55",
                "Filters": [
                    {
                        "CategoryFilter": {
                            "FilterId": "fe204e56-6701-49d4-91b9-9a42b5e40d31",
                            "Column": {
                                "DataSetIdentifier": "${SUPPORT_DATA_DATASET}",
                                "ColumnName": "Support Status"
                            },
                            "Configuration": {
                                "FilterListConfiguration": {
                                    "MatchOperator": "CONTAINS",
                                    "SelectAllOptions": "FILTER_ALL_VALUES",
                                    "NullOption": "NON_NULLS_ONLY"
                                }
                            }
                        }
                    }
                ],
                "ScopeConfiguration": {
                    "SelectedSheets": {
                        "SheetVisualScopingConfigurations": [
                            {
                                "SheetId": "bdb12279-a3ba-4ebc-b177-56d797ad7f3d_bbd4e626-2b1f-40f6-a6c7-c2acf7f1f896",
                                "Scope": "ALL_VISUALS"
                            }
                        ]
                    }
                },
                "Status": "ENABLED",
                "CrossDataset": "ALL_DATASETS"
            },
            {
                "FilterGroupId": "8b0cc240-c089-4783-a3db-d564f10c954a",
                "Filters": [
                    {
                        "CategoryFilter": {
                            "FilterId": "c9581083-c34f-4ede-bca9-7b14bf41f335",
                            "Column": {
                                "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                "ColumnName": "Account Id"
                            },
                            "Configuration": {
                                "FilterListConfiguration": {
                                    "MatchOperator": "CONTAINS",
                                    "SelectAllOptions": "FILTER_ALL_VALUES",
                                    "NullOption": "NON_NULLS_ONLY"
                                }
                            }
                        }
                    }
                ],
                "ScopeConfiguration": {
                    "SelectedSheets": {
                        "SheetVisualScopingConfigurations": [
                            {
                                "SheetId": "dbf1b80a-b1a3-4823-9bdc-7688fa9006ba_caa5ffbc-4e80-4c4e-9dec-ce1f358c21a0",
                                "Scope": "ALL_VISUALS"
                            }
                        ]
                    }
                },
                "Status": "ENABLED",
                "CrossDataset": "SINGLE_DATASET"
            },
            {
                "FilterGroupId": "e7046888-1db5-4359-abbe-38dda95cdc59",
                "Filters": [
                    {
                        "CategoryFilter": {
                            "FilterId": "27f289e6-5ebe-4e5e-8318-1509455ffe59",
                            "Column": {
                                "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                "ColumnName": "Region"
                            },
                            "Configuration": {
                                "FilterListConfiguration": {
                                    "MatchOperator": "CONTAINS",
                                    "SelectAllOptions": "FILTER_ALL_VALUES",
                                    "NullOption": "NON_NULLS_ONLY"
                                }
                            }
                        }
                    }
                ],
                "ScopeConfiguration": {
                    "SelectedSheets": {
                        "SheetVisualScopingConfigurations": [
                            {
                                "SheetId": "dbf1b80a-b1a3-4823-9bdc-7688fa9006ba_caa5ffbc-4e80-4c4e-9dec-ce1f358c21a0",
                                "Scope": "ALL_VISUALS"
                            }
                        ]
                    }
                },
                "Status": "ENABLED",
                "CrossDataset": "SINGLE_DATASET"
            },
            {
                "FilterGroupId": "9979f9ea-e6a3-4f73-8b22-150b548dd530",
                "Filters": [
                    {
                        "CategoryFilter": {
                            "FilterId": "6022313a-ace3-4c56-909e-d982be1e2873",
                            "Column": {
                                "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                "ColumnName": "Cluster Name"
                            },
                            "Configuration": {
                                "FilterListConfiguration": {
                                    "MatchOperator": "CONTAINS",
                                    "SelectAllOptions": "FILTER_ALL_VALUES",
                                    "NullOption": "NON_NULLS_ONLY"
                                }
                            }
                        }
                    }
                ],
                "ScopeConfiguration": {
                    "SelectedSheets": {
                        "SheetVisualScopingConfigurations": [
                            {
                                "SheetId": "dbf1b80a-b1a3-4823-9bdc-7688fa9006ba_caa5ffbc-4e80-4c4e-9dec-ce1f358c21a0",
                                "Scope": "ALL_VISUALS"
                            }
                        ]
                    }
                },
                "Status": "ENABLED",
                "CrossDataset": "SINGLE_DATASET"
            },
            {
                "FilterGroupId": "49ff3789-8d9d-4690-a6ee-f33825a86c2f",
                "Filters": [
                    {
                        "CategoryFilter": {
                            "FilterId": "7c03d733-63de-48a7-b797-15d3afcb2244",
                            "Column": {
                                "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                "ColumnName": "Argo Application Name"
                            },
                            "Configuration": {
                                "FilterListConfiguration": {
                                    "MatchOperator": "CONTAINS",
                                    "SelectAllOptions": "FILTER_ALL_VALUES",
                                    "NullOption": "NON_NULLS_ONLY"
                                }
                            }
                        }
                    }
                ],
                "ScopeConfiguration": {
                    "SelectedSheets": {
                        "SheetVisualScopingConfigurations": [
                            {
                                "SheetId": "dbf1b80a-b1a3-4823-9bdc-7688fa9006ba_caa5ffbc-4e80-4c4e-9dec-ce1f358c21a0",
                                "Scope": "ALL_VISUALS"
                            }
                        ]
                    }
                },
                "Status": "ENABLED",
                "CrossDataset": "SINGLE_DATASET"
            },
            {
                "FilterGroupId": "c67398e1-b22e-49d6-88d4-e2539653d1b4",
                "Filters": [
                    {
                        "CategoryFilter": {
                            "FilterId": "a937c571-57aa-4902-afd4-d8fb221eac1c",
                            "Column": {
                                "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                "ColumnName": "Application Health"
                            },
                            "Configuration": {
                                "FilterListConfiguration": {
                                    "MatchOperator": "CONTAINS",
                                    "SelectAllOptions": "FILTER_ALL_VALUES",
                                    "NullOption": "NON_NULLS_ONLY"
                                }
                            }
                        }
                    }
                ],
                "ScopeConfiguration": {
                    "SelectedSheets": {
                        "SheetVisualScopingConfigurations": [
                            {
                                "SheetId": "dbf1b80a-b1a3-4823-9bdc-7688fa9006ba_caa5ffbc-4e80-4c4e-9dec-ce1f358c21a0",
                                "Scope": "ALL_VISUALS"
                            }
                        ]
                    }
                },
                "Status": "ENABLED",
                "CrossDataset": "SINGLE_DATASET"
            },
            {
                "FilterGroupId": "79caf257-bae7-43c2-aaa7-b16f81b232ef",
                "Filters": [
                    {
                        "CategoryFilter": {
                            "FilterId": "b564dfa9-c40d-459e-9bb6-73d2b451c557",
                            "Column": {
                                "DataSetIdentifier": "${ARGO_PROJECTS_DATASET}",
                                "ColumnName": "Application Sync Status"
                            },
                            "Configuration": {
                                "FilterListConfiguration": {
                                    "MatchOperator": "CONTAINS",
                                    "SelectAllOptions": "FILTER_ALL_VALUES",
                                    "NullOption": "NON_NULLS_ONLY"
                                }
                            }
                        }
                    }
                ],
                "ScopeConfiguration": {
                    "SelectedSheets": {
                        "SheetVisualScopingConfigurations": [
                            {
                                "SheetId": "dbf1b80a-b1a3-4823-9bdc-7688fa9006ba_caa5ffbc-4e80-4c4e-9dec-ce1f358c21a0",
                                "Scope": "ALL_VISUALS"
                            }
                        ]
                    }
                },
                "Status": "ENABLED",
                "CrossDataset": "SINGLE_DATASET"
            }
        ],
        "AnalysisDefaults": {
            "DefaultNewSheetConfiguration": {
                "InteractiveLayoutConfiguration": {
                    "Grid": {
                        "CanvasSizeOptions": {
                            "ScreenCanvasSizeOptions": {
                                "ResizeOption": "FIXED",
                                "OptimizedViewPortWidth": "1600px"
                            }
                        }
                    }
                },
                "SheetContentType": "INTERACTIVE"
            }
        },
        "Options": {
            "WeekStart": "SUNDAY"
        }
    },
    "DashboardPublishOptions": {
        "AdHocFilteringOption": {
            "AvailabilityStatus": "DISABLED"
        },
        "ExportToCSVOption": {
            "AvailabilityStatus": "ENABLED"
        },
        "SheetControlsOption": {
            "VisibilityState": "COLLAPSED"
        },
        "SheetLayoutElementMaximizationOption": {
            "AvailabilityStatus": "ENABLED"
        },
        "VisualMenuOption": {
            "AvailabilityStatus": "ENABLED"
        },
        "VisualAxisSortOption": {
            "AvailabilityStatus": "ENABLED"
        },
        "ExportWithHiddenFieldsOption": {
            "AvailabilityStatus": "DISABLED"
        },
        "DataPointDrillUpDownOption": {
            "AvailabilityStatus": "ENABLED"
        },
        "DataPointMenuLabelOption": {
            "AvailabilityStatus": "ENABLED"
        },
        "DataPointTooltipOption": {
            "AvailabilityStatus": "ENABLED"
        }
    }
}
