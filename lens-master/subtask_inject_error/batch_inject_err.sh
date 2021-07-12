#!/bin/bash

matlab -r "inject_err('TM_Airport_period5_', 0, 12, 300, 300, 15); exit;"
matlab -r "inject_err('TM_Airport_period5_', 1, 12, 300, 300, 30); exit;"
matlab -r "inject_err('TM_Airport_period5_', 2, 12, 300, 300, 60); exit;"

