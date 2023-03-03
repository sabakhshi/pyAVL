# =============================================================================
# Extension modules
# =============================================================================
from pyavl import AVLSolver

# =============================================================================
# Standard Python Modules
# =============================================================================
import os

# =============================================================================
# External Python modules
# =============================================================================
import unittest
import numpy as np


base_dir = os.path.dirname(os.path.abspath(__file__))  # Path to current folder
geom_file = os.path.join(base_dir, "aircraft.avl")
mass_file = os.path.join(base_dir, "aircraft.mass")


class TestAnalysisSweep(unittest.TestCase):
    def setUp(self):
        self.avl_solver = AVLSolver(geo_file=geom_file, mass_file=mass_file)

    def test_constrained_alpha_sweep(self):
        self.avl_solver.add_constraint("Elevator", 0.00, con_var="Cm pitch moment")
        self.avl_solver.add_constraint("Rudder", 0.00, con_var="Cn yaw moment")

        alpha_array = np.arange(0, 10)
        cl_ref_arr = np.array(
            [
                1.2349061238204873,
                1.3282779560514677,
                1.42113603863798  ,
                1.5134418218893897,
                1.6051572516385355,
                1.6962448080698307,
                1.7866675434128751,
                1.8763891184181036,
                1.9653738375342211,
                2.053586682710641 
            ]
        )
        cd_ref_arr = np.array(
            [
                0.030753634421301752,
                0.033676747268002544,
                0.03679211508827116 ,
                0.040092804096450746,
                0.04357129507051221 ,
                0.047219503496354835,
                0.05102880128527856 ,
                0.0549900400052339  ,
                0.05909357556230493 ,
                0.06332929426488881 
            ]
        )
        for idx_alpha, alpha in enumerate(alpha_array):
            self.avl_solver.add_constraint("alpha", alpha)

            self.avl_solver.execute_run()
            run_data = self.avl_solver.get_case_total_data()
            
            np.testing.assert_allclose(
                cl_ref_arr[idx_alpha],
                run_data["CL"],
                rtol=1e-8,
            )
            np.testing.assert_allclose(
                cd_ref_arr[idx_alpha],
                run_data["CD"],
                rtol=1e-8,
            )
            np.testing.assert_allclose(
                run_data["CM"],
                0.0,
                atol=1e-8,
            )
            
    def test_constrained_cl_sweep(self):
        self.avl_solver.add_constraint("Elevator", 0.00, con_var="Cm pitch moment")
        self.avl_solver.add_constraint("Rudder", 0.00, con_var="Cn yaw moment")

        cd_ref_arr = np.array([
                            0.01654814255244833,
                            0.018124778345018383,
                            0.01994896285331091,
                            0.02202067604738557,
                            0.024339528639367926,
                            0.026904749658315106,
                            0.029715171166770832,
                            0.03276920986323026,
                            0.03606484526169707,
                            0.03959959407831794,
                            0.043370480383046583
                        ])
        cl_arr = np.arange(0.6, 1.7, 0.1)
        for idx_cl, cl in enumerate(cl_arr):
            self.avl_solver.add_trim_condition("CL", cl)
            self.avl_solver.execute_run()
            run_data = self.avl_solver.get_case_total_data()

            np.testing.assert_allclose(
                cl,
                run_data["CL"],
                rtol=1e-8,
            )
            np.testing.assert_allclose(
                cd_ref_arr[idx_cl],
                run_data["CD"],
                rtol=1e-8,
            )
            np.testing.assert_allclose(
                run_data["CM"],
                0.0,
                atol=1e-8,
            )


if __name__ == "__main__":
    unittest.main()
