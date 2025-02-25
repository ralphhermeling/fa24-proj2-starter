#include <stdio.h>
#include <stdlib.h>

int* read_matrix(const char* filepath, int* rows, int* cols) {
    FILE* file = fopen(filepath, "rb");  // Open file in binary read mode
    if (!file) {
        perror("Error opening file");
        exit(27);  // Exit with error code 27 if fopen fails
    }

    // Read number of rows and columns (each is a 4-byte integer)
    if (fread(rows, sizeof(int), 1, file) != 1 ||
        fread(cols, sizeof(int), 1, file) != 1) {
        perror("Error reading matrix dimensions");
        fclose(file);
        exit(29);  // Exit with error code 29 if fread fails
    }

    int matrix_size = (*rows) * (*cols);  // Total number of elements
    int* matrix = (int*)malloc(matrix_size * sizeof(int));  // Allocate heap memory
    if (!matrix) {
        perror("Error allocating memory");
        fclose(file);
        exit(26);  // Exit with error code 26 if malloc fails
    }

    // Read matrix data into allocated memory
    if (fread(matrix, sizeof(int), matrix_size, file) != matrix_size) {
        perror("Error reading matrix data");
        free(matrix);
        fclose(file);
        exit(29);  // Exit with error code 29 if fread fails
    }

    fclose(file);  // Close the file
    return matrix; // Return pointer to allocated matrix
}

// Example usage
int main(int argc, char* argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <matrix_file>\n", argv[0]);
        return 31;  // Error code for incorrect number of arguments
    }

    int rows, cols;
    int* matrix = read_matrix(argv[1], &rows, &cols);

    // Print the matrix
    printf("Matrix (%d x %d):\n", rows, cols);
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            printf("%d ", matrix[i * cols + j]);
        }
        printf("\n");
    }

    free(matrix);  // Free allocated memory
    return 0;
}
