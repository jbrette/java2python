class Break4 {
    public static void main(String[] args) {
        loop:
        while (true) {
            switch (3) {
            case 3:
                System.out.println("in case");
                break loop;
            default:
                System.out.println("not reached");
            }
        }
        System.out.println("after loop");
    }
}
