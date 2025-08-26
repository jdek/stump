#[cfg(test)]
mod tests {
	pub mod common;
}

#[macro_use]
extern crate slugify;

pub mod entity;
pub mod error;
pub mod prefixer;
pub mod shared;
