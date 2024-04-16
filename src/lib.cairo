use alexandria_math::sha256::sha256 as old_sha256;
use core::sha256::compute_sha256_u32_array;
use core::ArrayTrait;

fn main() -> felt252 {
    print!("Hello, world!\n");
    fib(16)
}

fn expand_slice(slice: [u32;8]) -> Array<u32> {
    let [v0, v1, v2, v3, v4, v5, v6, v7] = slice;
    array![v0, v1, v2, v3, v4, v5, v6, v7]
}

fn fib(mut n: felt252) -> felt252 {
    let mut a: felt252 = 0;
    let mut b: felt252 = 1;
    loop {
        if n == 0 {
            break a;
        }
        n = n - 1;
        let temp = b;
        b = a + b;
        a = temp;
    }
}

#[cfg(test)]
mod tests {
    use super::fib;

    #[test]
    fn it_works() {
        assert(fib(16) == 987, 'it works!');
    }
}
