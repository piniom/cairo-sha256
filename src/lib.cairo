use alexandria_math::sha256::sha256 as old_sha256;
use core::sha256::compute_sha256_u32_array;
use core::ArrayTrait;

// 1: Array<u8> -> Array<u32>
// 2: Array<u32> -> Array<u8>
// Wraper: new_sha256(Array<u8>) -> Array<u8>

fn main() -> () {
    let input_1 = array![1]; //u32
    let input_2 = array![0, 0, 0, 1,  0,0,1]; //u8
    let output_1 = expand_slice(compute_sha256_u32_array(input_1, 1, 3));
    let output_2 = old_sha256(input_2);
    println!("input1 = {:?}", output_1);
    println!("input2 =  {:?}", output_2);
}

fn expand_slice(slice: [u32;8]) -> Array<u32> {
    let [v0, v1, v2, v3, v4, v5, v6, v7] = slice;
    array![v0, v1, v2, v3, v4, v5, v6, v7]
}

#[cfg(test)]
mod tests {
}
