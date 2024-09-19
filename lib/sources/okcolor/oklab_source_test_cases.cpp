#include <cmath>
#include <cfloat>
#include <iostream>
#include <iomanip>
#include <vector>
#include "oklab_source.h"

using namespace ok_color;

RGB test_colors[] = {
	{0, 0, 0},     // Black
	{1, 1, 1},     // White
	{1, 0, 0},     // Red
	{0, 1, 0},     // Green
	{0, 0, 1},     // Blue
	{1, 1, 0},     // Yellow
	{0, 1, 1},     // Cyan
	{1, 0, 1},     // Magenta
	{0.5, 0.5, 0.5}, // Gray
	{0.7, 0.2, 0.3}, // Random color
	{0.1, 0.8, 0.6}, // Another random color
	{0.9, 0.1, 0.5}, // Pastel pink
	{0.3, 0.6, 0.1}, // Olive green
	{0.2, 0.4, 0.8}, // Sky blue
	{0.8, 0.5, 0.2}, // Orange
	{0.6, 0.4, 0.7}, // Lavender
	{0.1, 0.1, 0.1}, // Very dark gray
	{0.9, 0.9, 0.9}, // Very light gray
	{0.5, 0.0, 0.5}, // Purple
	{0.0, 0.5, 0.5}, // Teal
};

// ------------------------ Linear sRGB to sRGB test cases ------------------------ //

void test_linear_srgb_to_srgb(RGB color) {
    std::cout << std::fixed << std::setprecision(6);
    
    RGB linear = {
			srgb_transfer_function_inv(color.r),
			srgb_transfer_function_inv(color.g),
			srgb_transfer_function_inv(color.b)
		};
    RGB rgb_out = {
			srgb_transfer_function(linear.r),
			srgb_transfer_function(linear.g),
			srgb_transfer_function(linear.b)
		};
    
    std::cout << "RGB (" << color.r << ", " << color.g << ", " << color.b << ") -> "
              << "L_RGB (" << linear.r << ", " << linear.g << ", " << linear.b << ") -> "
              << "RGB (" << rgb_out.r << ", " << rgb_out.g << ", " << rgb_out.b << ")";

    float max_diff = std::max({std::abs(color.r - rgb_out.r),
                               std::abs(color.g - rgb_out.g),
                               std::abs(color.b - rgb_out.b)});

    if (max_diff < 1e-6) {
        std::cout << " PASS";
    } else {
        std::cout << " FAIL (Max difference: " << max_diff << ")";
    }
    std::cout << std::endl;
}

void linear_srgb_to_srgb_test_cases() {
    std::cout << "\nRunning Linear sRGB to sRGB conversion tests:" << std::endl;
    for (const auto& color : test_colors) {
        test_linear_srgb_to_srgb(color);
    }
}

// ------------------------ OkLab sRGB test cases ------------------------ //

void test_oklab_to_srgb(RGB rgb_in) {
    std::cout << std::fixed << std::setprecision(6);
    
    RGB linear = {
        srgb_transfer_function_inv(rgb_in.r),
        srgb_transfer_function_inv(rgb_in.g),
        srgb_transfer_function_inv(rgb_in.b)
    };
    Lab lab = linear_srgb_to_oklab(linear);
    RGB linear_back = oklab_to_linear_srgb(lab);
    RGB rgb_out = {
        srgb_transfer_function(linear_back.r),
        srgb_transfer_function(linear_back.g),
        srgb_transfer_function(linear_back.b)
    };

    std::cout << "RGB (" << rgb_in.r << ", " << rgb_in.g << ", " << rgb_in.b << ") -> "
              << "LAB (" << lab.L << ", " << lab.a << ", " << lab.b << ") -> "
              << "RGB (" << rgb_out.r << ", " << rgb_out.g << ", " << rgb_out.b << ")";

    float max_diff = std::max({std::abs(rgb_in.r - rgb_out.r),
                               std::abs(rgb_in.g - rgb_out.g),
                               std::abs(rgb_in.b - rgb_out.b)});

    if (max_diff < 1e-6) {
        std::cout << " PASS";
    } else {
        std::cout << " FAIL (Max difference: " << max_diff << ")";
    }
    std::cout << std::endl;
}

void oklab_srgb_test_cases() {
    int num_colors = sizeof(test_colors) / sizeof(test_colors[0]);

    std::cout << "\nRunning Oklab conversion tests:" << std::endl;
    for (int i = 0; i < num_colors; ++i) {
        test_oklab_to_srgb(test_colors[i]);
    }
}

// ------------------------ Compute max saturation test cases ------------------------ //

void test_compute_max_saturation(float a, float b) {
    float result = compute_max_saturation(a, b);
    std::cout << std::fixed << std::setprecision(6);
    std::cout << "compute_max_saturation(" << a << ", " << b << ") = " << result;
    
    // Check if the input is normalized
    float norm = a*a + b*b;
    if (std::abs(norm - 1.0f) > 1e-6) {
        std::cout << " (WARNING: Input not normalized, a^2 + b^2 = " << norm << ")";
    }
    std::cout << std::endl;
}

void compute_max_saturation_test_cases() {
    std::cout << "\nRunning compute_max_saturation tests:" << std::endl;

		test_compute_max_saturation(1, 0);         // Red
		test_compute_max_saturation(-0.5, 0.866025);   // Green
		test_compute_max_saturation(-0.5, -0.866025);  // Blue
		test_compute_max_saturation(0.5, 0.866025);    // Yellow
		test_compute_max_saturation(-1, 0);        // Cyan
		test_compute_max_saturation(0.5, -0.866025);   // Magenta
		test_compute_max_saturation(0.707107, 0.707107);   // 45 degrees
		test_compute_max_saturation(-0.707107, 0.707107);  // 135 degrees
		test_compute_max_saturation(-0.707107, -0.707107); // 225 degrees
		test_compute_max_saturation(0.707107, -0.707107);  // 315 degrees
		test_compute_max_saturation(0, 1);         // 90 degrees
		test_compute_max_saturation(0, -1);        // 270 degrees
		test_compute_max_saturation(1, 1);         // 22.5 degrees (not normalized)
		test_compute_max_saturation(-1, -1);       // 225 degrees (not normalized)
		test_compute_max_saturation(0, 0);         // Grayscale (undefined hue)
		test_compute_max_saturation(0.866025, 0.5);    // 30 degrees
		test_compute_max_saturation(-0.866025, 0.5);   // 150 degrees
		test_compute_max_saturation(-0.866025, -0.5);  // 210 degrees
		test_compute_max_saturation(0.866025, -0.5);   // 330 degrees
}

// ------------------------ Find cusp test cases ------------------------ //

void test_find_cusp(float a, float b) {
    LC result = find_cusp(a, b);
    std::cout << std::fixed << std::setprecision(6);
    std::cout << "find_cusp(" << a << ", " << b << ") = "
              << "L_cusp: " << result.L << ", C_cusp: " << result.C;

    // Check if input is normalized
    float norm = a*a + b*b;
    if (std::abs(norm - 1.0f) > 1e-6) {
        std::cout << " (WARNING: Input not normalized, a^2 + b^2 = " << norm << ")";
    }
    std::cout << std::endl;
}

void find_cusp_test_cases() {
    std::cout << "\nRunning find_cusp tests:" << std::endl;

		test_find_cusp(1, 0);             // Red
		test_find_cusp(-0.5, 0.866025);   // Green
		test_find_cusp(-0.5, -0.866025);  // Blue
		test_find_cusp(0.5, 0.866025);    // Yellow
		test_find_cusp(-1, 0);            // Cyan
		test_find_cusp(0.5, -0.866025);   // Magenta
		test_find_cusp(0.707107, 0.707107);   // 45 degrees
		test_find_cusp(-0.707107, 0.707107);  // 135 degrees
		test_find_cusp(-0.707107, -0.707107); // 225 degrees
		test_find_cusp(0.707107, -0.707107);  // 315 degrees
		test_find_cusp(0, 1);             // 90 degrees
		test_find_cusp(0, -1);            // 270 degrees
		test_find_cusp(0, 0);             // Grayscale (undefined hue)
		test_find_cusp(0.866025, 0.5);    // 30 degrees
		test_find_cusp(-0.866025, 0.5);   // 150 degrees
		test_find_cusp(-0.866025, -0.5);  // 210 degrees
		test_find_cusp(0.866025, -0.5);   // 330 degrees
		test_find_cusp(1, 1);             // Not normalized
		test_find_cusp(-2, -2);           // Not normalized
}

// ------------------------ Find gamut intersection test cases ------------------------ //

void test_find_gamut_intersection(float a, float b, float L1, float C1, float L0, LC cusp) {
    float result = find_gamut_intersection(a, b, L1, C1, L0, cusp);
    std::cout << std::fixed << std::setprecision(6);
    std::cout << "find_gamut_intersection(" 
              << a << ", " << b << ", " 
              << L1 << ", " << C1 << ", " 
              << L0 << ", {" << cusp.L << ", " << cusp.C << "}) = " 
              << result << std::endl;
}

void find_gamut_intersection_test_cases() {
    std::cout << "\nRunning find_gamut_intersection tests:" << std::endl;

		// Test cases
		test_find_gamut_intersection(1.0f, 0.0f, 0.5f, 0.1f, 0.7f, {0.8f, 0.3f});
		test_find_gamut_intersection(0.0f, 1.0f, 0.6f, 0.2f, 0.4f, {0.7f, 0.2f});
		test_find_gamut_intersection(-1.0f, 0.0f, 0.3f, 0.05f, 0.8f, {0.9f, 0.1f});
		test_find_gamut_intersection(0.0f, -1.0f, 0.7f, 0.15f, 0.5f, {0.6f, 0.25f});
		test_find_gamut_intersection(0.707107f, 0.707107f, 0.4f, 0.3f, 0.6f, {0.75f, 0.35f});
		test_find_gamut_intersection(-0.707107f, 0.707107f, 0.8f, 0.1f, 0.2f, {0.5f, 0.4f});
		test_find_gamut_intersection(0.5f, -0.866025f, 0.55f, 0.25f, 0.65f, {0.85f, 0.15f});
		test_find_gamut_intersection(-0.866025f, -0.5f, 0.35f, 0.18f, 0.75f, {0.95f, 0.05f});

		// Edge cases
		test_find_gamut_intersection(1.0f, 0.0f, 1.0f, 0.5f, 0.0f, {0.8f, 0.3f});
		test_find_gamut_intersection(0.0f, 1.0f, 0.0f, 0.5f, 1.0f, {0.7f, 0.2f});
		test_find_gamut_intersection(1.0f, 0.0f, 0.5f, 0.0f, 0.5f, {0.8f, 0.3f});
		test_find_gamut_intersection(0.0f, 1.0f, 0.5f, 1.0f, 0.5f, {0.7f, 0.2f});
}

// ------------------------ Common test cases ------------------------ //

void test_toe(float x) {
    float result = toe(x);
    std::cout << std::fixed << std::setprecision(6);
    std::cout << "toe(" << x << ") = " << result << std::endl;
}

void test_toe_inv(float x) {
    float result = toe_inv(x);
    std::cout << std::fixed << std::setprecision(6);
    std::cout << "toe_inv(" << x << ") = " << result << std::endl;
}

void test_to_ST(LC cusp) {
    ST result = to_ST(cusp);
    std::cout << std::fixed << std::setprecision(6);
    std::cout << "to_ST({" << cusp.L << ", " << cusp.C << "}) = {" << result.S << ", " << result.T << "}" << std::endl;
}

void test_get_ST_mid(float a_, float b_) {
    ST result = get_ST_mid(a_, b_);
    std::cout << std::fixed << std::setprecision(6);
    std::cout << "get_ST_mid(" << a_ << ", " << b_ << ") = {" << result.S << ", " << result.T << "}" << std::endl;
}

void test_get_Cs(float L, float a_, float b_) {
    Cs result = get_Cs(L, a_, b_);
    std::cout << std::fixed << std::setprecision(6);
    std::cout << "get_Cs(" << L << ", " << a_ << ", " << b_ << ") = {" 
              << result.C_0 << ", " << result.C_mid << ", " << result.C_max << "}" << std::endl;
}

void common_test_cases() {
    std::cout << "\nTesting toe function:" << std::endl;
    test_toe(0.0f);
    test_toe(0.5f);
    test_toe(1.0f);
    test_toe(0.25f);
    test_toe(0.75f);

    std::cout << "\nTesting toe_inv function:" << std::endl;
    test_toe_inv(0.0f);
    test_toe_inv(0.5f);
    test_toe_inv(1.0f);
    test_toe_inv(0.25f);
    test_toe_inv(0.75f);

    std::cout << "\nTesting to_ST function:" << std::endl;
    test_to_ST({0.5f, 0.5f});
    test_to_ST({0.75f, 0.25f});
    test_to_ST({0.25f, 0.75f});
    test_to_ST({0.1f, 0.9f});
    test_to_ST({0.9f, 0.1f});

    std::cout << "\nTesting get_ST_mid function:" << std::endl;
    test_get_ST_mid(0.0f, 0.0f);
    test_get_ST_mid(1.0f, 0.0f);
    test_get_ST_mid(0.0f, 1.0f);
    test_get_ST_mid(-1.0f, 0.0f);
    test_get_ST_mid(0.0f, -1.0f);
    test_get_ST_mid(0.5f, 0.5f);
    test_get_ST_mid(-0.5f, -0.5f);

    std::cout << "\nTesting get_Cs function:" << std::endl;
    test_get_Cs(0.5f, 0.0f, 0.0f);
    test_get_Cs(0.5f, 1.0f, 0.0f);
    test_get_Cs(0.5f, 0.0f, 1.0f);
    test_get_Cs(0.5f, -1.0f, 0.0f);
    test_get_Cs(0.5f, 0.0f, -1.0f);
    test_get_Cs(0.25f, 0.5f, 0.5f);
    test_get_Cs(0.75f, -0.5f, -0.5f);
}

// ------------------------ OkHSL sRGB test cases ------------------------ //

void test_okhsl_srgb(RGB original) {
  HSL hsl = srgb_to_okhsl(original);
  RGB converted = okhsl_to_srgb(hsl);
  
  double max_diff = std::max({std::abs(original.r - converted.r),
                              std::abs(original.g - converted.g),
                              std::abs(original.b - converted.b)});
  
  std::cout << std::fixed << std::setprecision(6);
  std::cout << "RGB (" << original.r << ", " << original.g << ", " << original.b << ") -> "
            << "HSL (" << hsl.h << ", " << hsl.s << ", " << hsl.l << ") -> "
            << "RGB (" << converted.r << ", " << converted.g << ", " << converted.b << ")";

  if (max_diff < 1e-6) {
    std::cout << " PASS";
  } else {
    std::cout << " FAIL (Max difference: " << max_diff << ")";
  }
  std::cout << std::endl;
}

void okhsl_srgb_test_cases() {
  int num_colors = sizeof(test_colors) / sizeof(test_colors[0]);

  std::cout << "\nRunning sRGB to OkHSL conversion tests:" << std::endl;
  for (int i = 0; i < num_colors; ++i) {
    test_okhsl_srgb(test_colors[i]);
  }
}

// ------------------------ OkHSV sRGB test cases ------------------------ //

void test_okhsv_srgb_conversion(RGB rgb_in) {
    std::cout << std::fixed << std::setprecision(6);
    
    HSV hsv = srgb_to_okhsv(rgb_in);
    RGB rgb_out = okhsv_to_srgb(hsv);
    
    std::cout << "RGB (" << rgb_in.r << ", " << rgb_in.g << ", " << rgb_in.b << ") -> "
              << "HSV (" << hsv.h << ", " << hsv.s << ", " << hsv.v << ") -> "
              << "RGB (" << rgb_out.r << ", " << rgb_out.g << ", " << rgb_out.b << ")";

    float max_diff = std::max({std::abs(rgb_in.r - rgb_out.r),
                               std::abs(rgb_in.g - rgb_out.g),
                               std::abs(rgb_in.b - rgb_out.b)});

    if (max_diff < 1e-6) {
        std::cout << " PASS";
    } else {
        std::cout << " FAIL (Max difference: " << max_diff << ")";
    }
    std::cout << std::endl;
}

void okhsv_srgb_test_cases() {
    std::cout << "\nRunning OkHSV to sRGB conversion tests:" << std::endl;
    for (const auto& color : test_colors) {
        test_okhsv_srgb_conversion(color);
    }
}

// ------------------------ Main ------------------------ //

int main() {
    linear_srgb_to_srgb_test_cases();
    compute_max_saturation_test_cases();
    find_cusp_test_cases();
    find_gamut_intersection_test_cases();
    common_test_cases();
    oklab_srgb_test_cases();
		okhsl_srgb_test_cases();
    okhsv_srgb_test_cases();
		return 0;
}

// Output:

// Running Linear sRGB to sRGB conversion tests:
// RGB (0.000000, 0.000000, 0.000000) -> L_RGB (0.000000, 0.000000, 0.000000) -> RGB (0.000000, 0.000000, 0.000000) PASS
// RGB (1.000000, 1.000000, 1.000000) -> L_RGB (1.000000, 1.000000, 1.000000) -> RGB (1.000000, 1.000000, 1.000000) PASS
// RGB (1.000000, 0.000000, 0.000000) -> L_RGB (1.000000, 0.000000, 0.000000) -> RGB (1.000000, 0.000000, 0.000000) PASS
// RGB (0.000000, 1.000000, 0.000000) -> L_RGB (0.000000, 1.000000, 0.000000) -> RGB (0.000000, 1.000000, 0.000000) PASS
// RGB (0.000000, 0.000000, 1.000000) -> L_RGB (0.000000, 0.000000, 1.000000) -> RGB (0.000000, 0.000000, 1.000000) PASS
// RGB (1.000000, 1.000000, 0.000000) -> L_RGB (1.000000, 1.000000, 0.000000) -> RGB (1.000000, 1.000000, 0.000000) PASS
// RGB (0.000000, 1.000000, 1.000000) -> L_RGB (0.000000, 1.000000, 1.000000) -> RGB (0.000000, 1.000000, 1.000000) PASS
// RGB (1.000000, 0.000000, 1.000000) -> L_RGB (1.000000, 0.000000, 1.000000) -> RGB (1.000000, 0.000000, 1.000000) PASS
// RGB (0.500000, 0.500000, 0.500000) -> L_RGB (0.214041, 0.214041, 0.214041) -> RGB (0.500000, 0.500000, 0.500000) PASS
// RGB (0.700000, 0.200000, 0.300000) -> L_RGB (0.447988, 0.033105, 0.073239) -> RGB (0.700000, 0.200000, 0.300000) PASS
// RGB (0.100000, 0.800000, 0.600000) -> L_RGB (0.010023, 0.603827, 0.318547) -> RGB (0.100000, 0.800000, 0.600000) PASS
// RGB (0.900000, 0.100000, 0.500000) -> L_RGB (0.787412, 0.010023, 0.214041) -> RGB (0.900000, 0.100000, 0.500000) PASS
// RGB (0.300000, 0.600000, 0.100000) -> L_RGB (0.073239, 0.318547, 0.010023) -> RGB (0.300000, 0.600000, 0.100000) PASS
// RGB (0.200000, 0.400000, 0.800000) -> L_RGB (0.033105, 0.132868, 0.603827) -> RGB (0.200000, 0.400000, 0.800000) PASS
// RGB (0.800000, 0.500000, 0.200000) -> L_RGB (0.603827, 0.214041, 0.033105) -> RGB (0.800000, 0.500000, 0.200000) PASS
// RGB (0.600000, 0.400000, 0.700000) -> L_RGB (0.318547, 0.132868, 0.447988) -> RGB (0.600000, 0.400000, 0.700000) PASS
// RGB (0.100000, 0.100000, 0.100000) -> L_RGB (0.010023, 0.010023, 0.010023) -> RGB (0.100000, 0.100000, 0.100000) PASS
// RGB (0.900000, 0.900000, 0.900000) -> L_RGB (0.787412, 0.787412, 0.787412) -> RGB (0.900000, 0.900000, 0.900000) PASS
// RGB (0.500000, 0.000000, 0.500000) -> L_RGB (0.214041, 0.000000, 0.214041) -> RGB (0.500000, 0.000000, 0.500000) PASS
// RGB (0.000000, 0.500000, 0.500000) -> L_RGB (0.000000, 0.214041, 0.214041) -> RGB (0.000000, 0.500000, 0.500000) PASS

// Running compute_max_saturation tests:
// compute_max_saturation(1.000000, 0.000000) = 0.405391
// compute_max_saturation(-0.500000, 0.866025) = 0.237417
// compute_max_saturation(-0.500000, -0.866025) = 0.229061
// compute_max_saturation(0.500000, 0.866025) = 0.234513
// compute_max_saturation(-1.000000, 0.000000) = 0.181430
// compute_max_saturation(0.500000, -0.866025) = 0.533082
// compute_max_saturation(0.707107, 0.707107) = 0.285900
// compute_max_saturation(-0.707107, 0.707107) = 0.292061
// compute_max_saturation(-0.707107, -0.707107) = 0.189467
// compute_max_saturation(0.707107, -0.707107) = 0.492243
// compute_max_saturation(0.000000, 1.000000) = 0.204357
// compute_max_saturation(0.000000, -1.000000) = 0.655372
// compute_max_saturation(1.000000, 1.000000) = 0.110804 (WARNING: Input not normalized, a^2 + b^2 = 2.000000)
// compute_max_saturation(-1.000000, -1.000000) = 0.133977 (WARNING: Input not normalized, a^2 + b^2 = 2.000000)
// compute_max_saturation(0.000000, 0.000000) = nan (WARNING: Input not normalized, a^2 + b^2 = 0.000000)
// compute_max_saturation(0.866025, 0.500000) = 0.401059
// compute_max_saturation(-0.866025, 0.500000) = 0.275397
// compute_max_saturation(-0.866025, -0.500000) = 0.172948
// compute_max_saturation(0.866025, -0.500000) = 0.455754

// Running find_cusp tests:
// find_cusp(1.000000, 0.000000) = L_cusp: 0.647704, C_cusp: 0.262574
// find_cusp(-0.500000, 0.866025) = L_cusp: 0.939571, C_cusp: 0.223070
// find_cusp(-0.500000, -0.866025) = L_cusp: 0.717402, C_cusp: 0.164329
// find_cusp(0.500000, 0.866025) = L_cusp: 0.756457, C_cusp: 0.177399
// find_cusp(-1.000000, 0.000000) = L_cusp: 0.895963, C_cusp: 0.162555
// find_cusp(0.500000, -0.866025) = L_cusp: 0.552545, C_cusp: 0.294552
// find_cusp(0.707107, 0.707107) = L_cusp: 0.701853, C_cusp: 0.200660
// find_cusp(-0.707107, 0.707107) = L_cusp: 0.893696, C_cusp: 0.261014
// find_cusp(-0.707107, -0.707107) = L_cusp: 0.782650, C_cusp: 0.148286
// find_cusp(0.707107, -0.707107) = L_cusp: 0.620074, C_cusp: 0.305227
// find_cusp(0.000000, 1.000000) = L_cusp: 0.863629, C_cusp: 0.176489
// find_cusp(0.000000, -1.000000) = L_cusp: 0.464921, C_cusp: 0.304696
// find_cusp(0.000000, 0.000000) = L_cusp: nan, C_cusp: nan (WARNING: Input not normalized, a^2 + b^2 = 0.000000)
// find_cusp(0.866025, 0.500000) = L_cusp: 0.632284, C_cusp: 0.253583
// find_cusp(-0.866025, 0.500000) = L_cusp: 0.873998, C_cusp: 0.240697
// find_cusp(-0.866025, -0.500000) = L_cusp: 0.841330, C_cusp: 0.145506
// find_cusp(0.866025, -0.500000) = L_cusp: 0.697316, C_cusp: 0.317805
// find_cusp(1.000000, 1.000000) = L_cusp: 0.796463, C_cusp: 0.088252 (WARNING: Input not normalized, a^2 + b^2 = 2.000000)
// find_cusp(-2.000000, -2.000000) = L_cusp: 0.240156, C_cusp: 0.218149 (WARNING: Input not normalized, a^2 + b^2 = 8.000000)

// Running find_gamut_intersection tests:
// find_gamut_intersection(1.000000, 0.000000, 0.500000, 0.100000, 0.700000, {0.800000, 0.300000}) = 1.500000
// find_gamut_intersection(0.000000, 1.000000, 0.600000, 0.200000, 0.400000, {0.700000, 0.200000}) = 0.800000
// find_gamut_intersection(-1.000000, 0.000000, 0.300000, 0.050000, 0.800000, {0.900000, 0.100000}) = 0.842105
// find_gamut_intersection(0.000000, -1.000000, 0.700000, 0.150000, 0.500000, {0.600000, 0.250000}) = 1.024120
// find_gamut_intersection(0.707107, 0.707107, 0.400000, 0.300000, 0.600000, {0.750000, 0.350000}) = 0.711864
// find_gamut_intersection(-0.707107, 0.707107, 0.800000, 0.100000, 0.200000, {0.500000, 0.400000}) = 1.236430
// find_gamut_intersection(0.500000, -0.866025, 0.550000, 0.250000, 0.650000, {0.850000, 0.150000}) = 0.428571
// find_gamut_intersection(-0.866025, -0.500000, 0.350000, 0.180000, 0.750000, {0.950000, 0.050000}) = 0.196335
// find_gamut_intersection(1.000000, 0.000000, 1.000000, 0.500000, 0.000000, {0.800000, 0.300000}) = 0.000000
// find_gamut_intersection(0.000000, 1.000000, 0.000000, 0.500000, 1.000000, {0.700000, 0.200000}) = 0.363636
// find_gamut_intersection(1.000000, 0.000000, 0.500000, 0.000000, 0.500000, {0.800000, 0.300000}) = inf
// find_gamut_intersection(0.000000, 1.000000, 0.500000, 1.000000, 0.500000, {0.700000, 0.200000}) = 0.142857

// Testing toe function:
// toe(0.000000) = 0.000000
// toe(0.500000) = 0.421141
// toe(1.000000) = 1.000000
// toe(0.250000) = 0.146614
// toe(0.750000) = 0.709297

// Testing toe_inv function:
// toe_inv(0.000000) = 0.000000
// toe_inv(0.500000) = 0.568838
// toe_inv(1.000000) = 1.000000
// toe_inv(0.250000) = 0.347726
// toe_inv(0.750000) = 0.785081

// Testing to_ST function:
// to_ST({0.500000, 0.500000}) = {1.000000, 1.000000}
// to_ST({0.750000, 0.250000}) = {0.333333, 1.000000}
// to_ST({0.250000, 0.750000}) = {3.000000, 1.000000}
// to_ST({0.100000, 0.900000}) = {9.000000, 1.000000}
// to_ST({0.900000, 0.100000}) = {0.111111, 1.000000}

// Testing get_ST_mid function:
// get_ST_mid(0.000000, 0.000000) = {0.249438, 0.732281}
// get_ST_mid(1.000000, 0.000000) = {0.395665, 0.736459}
// get_ST_mid(0.000000, 1.000000) = {0.201326, 1.185405}
// get_ST_mid(-1.000000, 0.000000) = {0.175945, 1.379813}
// get_ST_mid(0.000000, -1.000000) = {0.419234, 0.548231}
// get_ST_mid(0.500000, 0.500000) = {0.254452, 0.710679}
// get_ST_mid(-0.500000, -0.500000) = {0.229011, 0.669444}

// Testing get_Cs function:
// get_Cs(0.500000, 0.000000, 0.000000) = {0.178885, nan, nan}
// get_Cs(0.500000, 1.000000, 0.000000) = {0.178885, 0.174522, 0.202696}
// get_Cs(0.500000, 0.000000, 1.000000) = {0.178885, 0.090578, 0.102179}
// get_Cs(0.500000, -1.000000, 0.000000) = {0.178885, 0.079170, 0.090715}
// get_Cs(0.500000, 0.000000, -1.000000) = {0.178885, 0.173104, 0.281184}
// get_Cs(0.250000, 0.500000, 0.500000) = {0.098639, 0.057249, 0.105430}
// get_Cs(0.750000, -0.500000, -0.500000) = {0.166410, 0.128270, 0.201008}

// Running Oklab conversion tests:
// RGB (0.000000, 0.000000, 0.000000) -> LAB (0.000000, 0.000000, 0.000000) -> RGB (0.000000, 0.000000, 0.000000) PASS
// RGB (1.000000, 1.000000, 1.000000) -> LAB (1.000000, 0.000000, 0.000000) -> RGB (1.000000, 1.000000, 1.000000) PASS
// RGB (1.000000, 0.000000, 0.000000) -> LAB (0.627955, 0.224863, 0.125846) -> RGB (1.000000, 0.000001, -0.000000) PASS
// RGB (0.000000, 1.000000, 0.000000) -> LAB (0.866440, -0.233887, 0.179498) -> RGB (0.000003, 1.000000, -0.000003) FAIL (Max difference: 0.000003)
// RGB (0.000000, 0.000000, 1.000000) -> LAB (0.452014, -0.032457, -0.311528) -> RGB (0.000001, -0.000001, 1.000000) FAIL (Max difference: 0.000001)
// RGB (1.000000, 1.000000, 0.000000) -> LAB (0.967983, -0.071369, 0.198570) -> RGB (1.000000, 1.000000, -0.000000) PASS
// RGB (0.000000, 1.000000, 1.000000) -> LAB (0.905399, -0.149444, -0.039398) -> RGB (0.000007, 1.000000, 1.000000) FAIL (Max difference: 0.000007)
// RGB (1.000000, 0.000000, 1.000000) -> LAB (0.701674, 0.274566, -0.169156) -> RGB (1.000000, -0.000001, 1.000000) FAIL (Max difference: 0.000001)
// RGB (0.500000, 0.500000, 0.500000) -> LAB (0.598181, 0.000000, 0.000000) -> RGB (0.500000, 0.500000, 0.500000) PASS
// RGB (0.700000, 0.200000, 0.300000) -> LAB (0.519632, 0.158814, 0.038012) -> RGB (0.700000, 0.200000, 0.300000) PASS
// RGB (0.100000, 0.800000, 0.600000) -> LAB (0.751552, -0.146994, 0.035401) -> RGB (0.100001, 0.800000, 0.600000) PASS
// RGB (0.900000, 0.100000, 0.500000) -> LAB (0.606135, 0.236190, -0.005215) -> RGB (0.900000, 0.100000, 0.500000) PASS
// RGB (0.300000, 0.600000, 0.100000) -> LAB (0.610136, -0.124724, 0.118676) -> RGB (0.300001, 0.600000, 0.100000) PASS
// RGB (0.200000, 0.400000, 0.800000) -> LAB (0.532483, -0.022512, -0.166349) -> RGB (0.200000, 0.400000, 0.800000) PASS
// RGB (0.800000, 0.500000, 0.200000) -> LAB (0.665835, 0.061456, 0.114605) -> RGB (0.800000, 0.500000, 0.200000) PASS
// RGB (0.600000, 0.400000, 0.700000) -> LAB (0.594006, 0.086594, -0.090579) -> RGB (0.600000, 0.400000, 0.700000) PASS
// RGB (0.100000, 0.100000, 0.100000) -> LAB (0.215607, 0.000000, -0.000000) -> RGB (0.100000, 0.100000, 0.100000) PASS
// RGB (0.900000, 0.900000, 0.900000) -> LAB (0.923423, 0.000000, -0.000000) -> RGB (0.900000, 0.900000, 0.900000) PASS
// RGB (0.500000, 0.000000, 0.500000) -> LAB (0.419728, 0.164240, -0.101186) -> RGB (0.500000, 0.000000, 0.500000) PASS
// RGB (0.000000, 0.500000, 0.500000) -> LAB (0.541592, -0.089394, -0.023567) -> RGB (0.000003, 0.500000, 0.500000) FAIL (Max difference: 0.000003)

// Running sRGB to OkHSL conversion tests:
// RGB (0.000000, 0.000000, 0.000000) -> HSL (0.000000, nan, 0.000000) -> RGB (0.000000, 0.000000, 0.000000) PASS
// RGB (1.000000, 1.000000, 1.000000) -> HSL (0.250000, nan, 1.000000) -> RGB (1.000000, 1.000000, 1.000000) PASS
// RGB (1.000000, 0.000000, 0.000000) -> HSL (0.081205, 1.000000, 0.568085) -> RGB (1.000000, 0.000002, -0.000000) FAIL (Max difference: 0.000002)
// RGB (0.000000, 1.000000, 0.000000) -> HSL (0.395820, 1.000000, 0.844529) -> RGB (0.000003, 1.000000, -0.000003) FAIL (Max difference: 0.000003)
// RGB (0.000000, 0.000000, 1.000000) -> HSL (0.733478, 1.000000, 0.366565) -> RGB (0.000001, -0.000001, 1.000000) PASS
// RGB (1.000000, 1.000000, 0.000000) -> HSL (0.304915, 1.000000, 0.962704) -> RGB (1.000000, 1.000000, 0.000002) FAIL (Max difference: 0.000002)
// RGB (0.000000, 1.000000, 1.000000) -> HSL (0.541025, 1.000000, 0.889848) -> RGB (-0.000005, 1.000000, 1.000000) FAIL (Max difference: 0.000005)
// RGB (1.000000, 0.000000, 1.000000) -> HSL (0.912121, 1.000039, 0.653299) -> RGB (1.000000, -0.000002, 1.000000) FAIL (Max difference: 0.000002)
// RGB (0.500000, 0.500000, 0.500000) -> HSL (0.136387, 0.000000, 0.533760) -> RGB (0.500000, 0.500000, 0.500000) PASS
// RGB (0.700000, 0.200000, 0.300000) -> HSL (0.037391, 0.775071, 0.443573) -> RGB (0.700000, 0.200000, 0.300000) PASS
// RGB (0.100000, 0.800000, 0.600000) -> HSL (0.462387, 0.962914, 0.711097) -> RGB (0.100001, 0.800000, 0.600000) PASS
// RGB (0.900000, 0.100000, 0.500000) -> HSL (0.996487, 0.949953, 0.542923) -> RGB (0.900000, 0.100000, 0.500000) PASS
// RGB (0.300000, 0.600000, 0.100000) -> HSL (0.378954, 0.971604, 0.547534) -> RGB (0.300000, 0.600000, 0.100000) PASS
// RGB (0.200000, 0.400000, 0.800000) -> HSL (0.728592, 0.825065, 0.458283) -> RGB (0.200000, 0.400000, 0.800000) PASS
// RGB (0.800000, 0.500000, 0.200000) -> HSL (0.171661, 0.775658, 0.611836) -> RGB (0.800000, 0.500000, 0.199999) PASS
// RGB (0.600000, 0.400000, 0.700000) -> HSL (0.871421, 0.531781, 0.528952) -> RGB (0.600000, 0.400000, 0.700000) PASS
// RGB (0.100000, 0.100000, 0.100000) -> HSL (0.985120, 0.000000, 0.113296) -> RGB (0.100000, 0.100000, 0.100000) PASS
// RGB (0.900000, 0.900000, 0.900000) -> HSL (0.976477, 0.000002, 0.910824) -> RGB (0.900000, 0.900000, 0.900000) PASS
// RGB (0.500000, 0.000000, 0.500000) -> HSL (0.912121, 1.000620, 0.330110) -> RGB (0.500000, 0.000001, 0.500000) PASS
// RGB (0.000000, 0.500000, 0.500000) -> HSL (0.541025, 0.999999, 0.468723) -> RGB (0.000001, 0.500000, 0.500000) FAIL (Max difference: 0.000001)

// Running OkHSV to sRGB conversion tests:
// RGB (0.000000, 0.000000, 0.000000) -> HSV (0.000000, nan, nan) -> RGB (nan, nan, nan) FAIL (Max difference: nan)
// RGB (1.000000, 1.000000, 1.000000) -> HSV (0.250000, 0.000000, 1.000000) -> RGB (1.000000, 1.000000, 1.000000) PASS
// RGB (1.000000, 0.000000, 0.000000) -> HSV (0.081205, 1.000000, 1.000000) -> RGB (1.000000, 0.000001, -0.000000) PASS
// RGB (0.000000, 1.000000, 0.000000) -> HSV (0.395820, 1.000000, 1.000000) -> RGB (0.000009, 1.000000, -0.000003) FAIL (Max difference: 0.000009)
// RGB (0.000000, 0.000000, 1.000000) -> HSV (0.733478, 0.999991, 1.000000) -> RGB (0.000001, -0.000001, 1.000000) FAIL (Max difference: 0.000001)
// RGB (1.000000, 1.000000, 0.000000) -> HSV (0.304915, 1.000000, 1.000000) -> RGB (1.000000, 1.000000, 0.000001) FAIL (Max difference: 0.000001)
// RGB (0.000000, 1.000000, 1.000000) -> HSV (0.541025, 1.000000, 1.000000) -> RGB (0.000003, 1.000000, 1.000000) FAIL (Max difference: 0.000003)
// RGB (1.000000, 0.000000, 1.000000) -> HSV (0.912121, 1.000122, 1.000000) -> RGB (1.000000, -0.000000, 1.000000) PASS
// RGB (0.500000, 0.500000, 0.500000) -> HSV (0.136387, 0.000000, 0.533760) -> RGB (0.500000, 0.500000, 0.500000) PASS
// RGB (0.700000, 0.200000, 0.300000) -> HSV (0.037391, 0.834492, 0.711834) -> RGB (0.700000, 0.200000, 0.300000) PASS
// RGB (0.100000, 0.800000, 0.600000) -> HSV (0.462387, 0.954817, 0.816986) -> RGB (0.100001, 0.800000, 0.600000) PASS
// RGB (0.900000, 0.100000, 0.500000) -> HSV (0.996487, 0.969158, 0.905012) -> RGB (0.900000, 0.100000, 0.500000) PASS
// RGB (0.300000, 0.600000, 0.100000) -> HSV (0.378954, 0.920810, 0.626223) -> RGB (0.300000, 0.600000, 0.100000) PASS
// RGB (0.200000, 0.400000, 0.800000) -> HSV (0.728592, 0.782249, 0.807227) -> RGB (0.200000, 0.400000, 0.800000) PASS
// RGB (0.800000, 0.500000, 0.200000) -> HSV (0.171661, 0.810606, 0.813831) -> RGB (0.800000, 0.500000, 0.200000) PASS
// RGB (0.600000, 0.400000, 0.700000) -> HSV (0.871421, 0.545854, 0.717722) -> RGB (0.600000, 0.400000, 0.700000) PASS
// RGB (0.100000, 0.100000, 0.100000) -> HSV (0.985120, 0.000001, 0.113296) -> RGB (0.100000, 0.100000, 0.100000) PASS
// RGB (0.900000, 0.900000, 0.900000) -> HSV (0.976477, 0.000000, 0.910824) -> RGB (0.900000, 0.900000, 0.900000) PASS
// RGB (0.500000, 0.000000, 0.500000) -> HSV (0.912121, 1.000122, 0.510620) -> RGB (0.500000, -0.000000, 0.500000) PASS
// RGB (0.000000, 0.500000, 0.500000) -> HSV (0.541025, 0.999999, 0.527824) -> RGB (0.000001, 0.500000, 0.500000) FAIL (Max difference: 0.000001)